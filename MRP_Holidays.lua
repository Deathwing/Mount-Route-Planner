-- MRP_Holidays.lua
-- local _, MRP = ...

-- Scans the in-game C_Calendar API to determine which holiday events
-- are currently active. Follows the same approach as AllTheThings:
-- scan a range of months, cache events where calendarType == "HOLIDAY",
-- and expose a simple "is this event active right now?" check.

local Holidays = {}
MRP.Holidays = Holidays

--- Cached table of active holiday events:  { [eventID] = { startTime, endTime } }
local activeHolidays = nil
--- Timestamp when the cache was last built
local holidayCacheTime = 0
--- How long to keep the cache valid (seconds) — refresh every 30 minutes
local HOLIDAY_CACHE_TTL = 1800

--- Build a unix timestamp from a CalendarTime table.
---@param ct table A CalendarTime-like table with year/month/monthDay/hour/minute
---@return number timestamp
local function CalendarTimeToTimestamp(ct)
    if not ct or not ct.year then return 0 end
    return time({
        year = ct.year,
        month = ct.month,
        day = ct.monthDay,
        hour = ct.hour or 0,
        min = ct.minute or 0,
        sec = 0,
    })
end

--- Scan the C_Calendar API for active and upcoming holiday events.
--- Populates `activeHolidays` keyed by eventID.
local function ScanCalendarHolidays()
    if not C_Calendar then return end

    local now = time()
    -- Only rebuild if cache is stale
    if activeHolidays and (now - holidayCacheTime) < HOLIDAY_CACHE_TTL then
        return
    end

    activeHolidays = {}
    holidayCacheTime = now

    local currentDate = C_DateAndTime.GetCurrentCalendarTime()
    if not currentDate then return end

    local currentMonth = currentDate.month
    local currentYear = currentDate.year

    -- Scan current month ±1 to catch events that span month boundaries
    for monthOffset = -1, 1 do
        local m = currentMonth + monthOffset
        local y = currentYear
        if m < 1 then
            m = m + 12
            y = y - 1
        elseif m > 12 then
            m = m - 12
            y = y + 1
        end

        C_Calendar.SetAbsMonth(m, y)
        local numDays = C_Calendar.GetMonthInfo().numDays or 31

        for day = 1, numDays do
            local numEvents = C_Calendar.GetNumDayEvents(0, day)
            for i = 1, numEvents do
                local event = C_Calendar.GetDayEvent(0, day, i)
                if event and event.calendarType == "HOLIDAY" and event.eventID then
                    local startTS = CalendarTimeToTimestamp(event.startTime)
                    local endTS = CalendarTimeToTimestamp(event.endTime)
                    -- Keep the widest window if we see the same event multiple times
                    local existing = activeHolidays[event.eventID]
                    if existing then
                        if startTS < existing.startTime then existing.startTime = startTS end
                        if endTS > existing.endTime then existing.endTime = endTS end
                    else
                        activeHolidays[event.eventID] = { startTime = startTS, endTime = endTS }
                    end
                end
            end
        end
    end

    -- Reset calendar view back to current month
    C_Calendar.SetAbsMonth(currentMonth, currentYear)
end

--- Check if a holiday event identified by its condition string is currently active.
--- Uses the mapping table in MRP.HolidayCalendarEventIDs to resolve condition
--- strings like "event_brewfest" into calendar event IDs.
---@param holidayCondition string e.g. "event_brewfest"
---@return boolean
function Holidays:IsHolidayEventActive(holidayCondition)
    ScanCalendarHolidays()
    if not activeHolidays then
        -- Calendar API not available (e.g. Classic without calendar); allow through
        return true
    end

    local knownIDs = MRP.HolidayCalendarEventIDs[holidayCondition]
    if not knownIDs then
        -- Unknown holiday condition — allow through to be safe
        return true
    end

    local now = time()
    for _, eventID in ipairs(knownIDs) do
        local entry = activeHolidays[eventID]
        if entry and now >= entry.startTime and now <= entry.endTime then
            return true
        end
    end

    return false
end
