const express = require('express');

const app = express();

app.use(express.json());

const PORT = 3000;

const employee = {
    id: "REBS001",
    name: "Sangeerth Raj",
    department: "Mobile Development",
    companyTimezone: "Asia/Kolkata",

    office: {
        latitude: 11.8745,
        longitude: 75.3738,
        allowedRadiusMeters: 200
    }
};

let attendance = [];

let leaveRequests = [];

let acceptedEvents = new Map();

const leaveBalance = 12;

const scenario = process.env.SCENARIO || "success";

// Company date in configured timezone
function companyDate(value = new Date()) {
    const parts = new Intl.DateTimeFormat("en-CA", {
        timeZone: employee.companyTimezone,
        year: "numeric",
        month: "2-digit",
        day: "2-digit"
    }).formatToParts(value);

    const values = {};

    parts.forEach(p => {
        values[p.type] = p.value;
    });

    return `${values.year}-${values.month}-${values.day}`;
}

// Mock scenarios
app.use((req, res, next) => {
    if (scenario === "slow") {
        return setTimeout(next, 16000);
    }

    if (
        scenario === "server-error" &&
        req.path !== "/health"
    ) {
        return res.status(500).json({
            message: "Simulated server error"
        });
    }

    next();
});

// Health check
app.get("/health", (req, res) => {
    res.json({
        success: true,
        scenario
    });
});

// Employee
app.get("/employee/me", (req, res) => {
    res.json(employee);
});

// Attendance history
app.get("/attendance", (req, res) => {
    res.json({
        data: attendance
    });
});

// Leave balance
app.get("/leave/balance", (req, res) => {
    res.json({
        availableDays: leaveBalance
    });
});

// Leave requests
app.get("/leave/requests", (req, res) => {
    res.json({
        data: leaveRequests
    });
});

// Attendance events
app.post("/attendance/events", (req, res) => {
    const event = req.body;

    const {
        eventId,
        type,
        occurredAt,
        latitude,
        longitude
    } = event;

    if (!eventId || !occurredAt ||
        !["CHECK_IN", "CHECK_OUT"].includes(type) ||
        !Number.isFinite(latitude) ||
        !Number.isFinite(longitude)) {
        return res.status(400).json({
            message: "Invalid attendance event."
        });
    }

    // Idempotency: same event ID returns previous success.
    if (acceptedEvents.has(eventId)) {
        return res.status(200).json({
            success: true,
            duplicateRetry: true,
            eventId
        });
    }

    const eventDate = companyDate(new Date(occurredAt));

    const today = companyDate();

    if (eventDate !== today) {
        return res.status(422).json({
            message: "Attendance date is not the current company date."
        });
    }

    // Validate server-side GPS.
    const earthRadius = 6371000;

    const toRad = value => value * Math.PI / 180;

    const dLat = toRad(latitude - employee.office.latitude);
    const dLon = toRad(longitude - employee.office.longitude);

    const a =
        Math.sin(dLat / 2) ** 2 +
        Math.cos(toRad(employee.office.latitude)) *
        Math.cos(toRad(latitude)) *
        Math.sin(dLon / 2) ** 2;

    const distance =
        2 * earthRadius * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    if (distance > employee.office.allowedRadiusMeters) {
        return res.status(422).json({
            message: "You are outside the permitted office area."
        });
    }

    let record = attendance.find(
        item => companyDate(new Date(item.checkInAt)) === eventDate
    );

    if (type === "CHECK_IN") {
        if (record) {
            return res.status(409).json({
                message: "Attendance already exists for today."
            });
        }

        record = {
            id: "ATT-" + eventId,
            checkInAt: occurredAt,
            checkOutAt: null,
            syncStatus: "Synced"
        };

        attendance.unshift(record);
    }

    if (type === "CHECK_OUT") {
        if (!record || record.checkOutAt) {
            return res.status(409).json({
                message: "No open check-in exists."
            });
        }

        if (new Date(occurredAt) <= new Date(record.checkInAt)) {
            return res.status(422).json({
                message: "Check-out must be after check-in."
            });
        }

        record.checkOutAt = occurredAt;
    }

    // Store the event ID only after successful acceptance.
    acceptedEvents.set(eventId, true);

    res.status(201).json({
        success: true,
        eventId
    });
});

// Leave application
app.post("/leave/requests", (req, res) => {
    const {
        type,
        startDate,
        endDate,
        reason
    } = req.body;

    if (scenario === "leave-reject") {
        return res.status(422).json({
            message: "Simulated company leave policy rejection."
        });
    }

    if (
        !["Casual", "Sick"].includes(type) ||
        !startDate ||
        !endDate ||
        !reason ||
        reason.trim().length < 10
    ) {
        return res.status(422).json({
            message: "Invalid leave information."
        });
    }

    const start = new Date(startDate);
    const end = new Date(endDate);

    if (Number.isNaN(start.getTime()) ||
        Number.isNaN(end.getTime())) {
        return res.status(422).json({
            message: "Invalid leave dates."
        });
    }

    const startDay = companyDate(start);
    const endDay = companyDate(end);

    if (startDay < companyDate()) {
        return res.status(422).json({
            message: "Start date cannot be in the past."
        });
    }

    if (endDay < startDay) {
        return res.status(422).json({
            message: "End date cannot precede start date."
        });
    }

    const overlapping = leaveRequests.some(request => {
        if (
            request.status !== "Pending" &&
            request.status !== "Approved"
        ) {
            return false;
        }

        const existingStart = companyDate(new Date(request.startDate));
        const existingEnd = companyDate(new Date(request.endDate));

        return startDay <= existingEnd &&
            endDay >= existingStart;
    });

    if (overlapping) {
        return res.status(422).json({
            message: "Dates overlap an existing leave request."
        });
    }

    const days =
        Math.round((Date.parse(endDay) - Date.parse(startDay)) / 86400000) + 1;

    if (days > leaveBalance) {
        return res.status(422).json({
            message: "Insufficient leave balance."
        });
    }

    const request = {
        id: "LR" + (leaveRequests.length + 1),
        type,
        startDate,
        endDate,
        reason: reason.trim(),
        status: "Pending"
    };

    leaveRequests.push(request);

    res.status(201).json(request);
});

app.listen(PORT, "0.0.0.0", () => {
    console.log(`REBS API running at http://localhost:${PORT}`);
    console.log(`Scenario: ${scenario}`);
});