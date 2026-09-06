/* ============================================================
   SYSTEM ADMINISTRATOR 1
   CALGARY ENDPOINT MANAGEMENT
   Endpoint Monitoring & Risk Analysis
   Database: CalgaryEndpointManagement
   Table:    dbo.Endpoints
   ============================================================ */


USE CalgaryEndpointManagement;
GO


/* ============================================================
   01. ENDPOINT RISK SCORE
   ------------------------------------------------------------
   Calculates a weighted risk score for each endpoint based on:
       - Network connectivity
       - Microsoft Defender status
       - Available disk space
       - System uptime
   ============================================================ */

SELECT
    EndpointID,
    ComputerName,
    FreeDiskPercent,
    UptimeDays,
    NetworkStatus,
    DefenderStatus,
    BitLockerStatus,
    HealthStatus,
    HealthReason,

    (
        CASE
            WHEN NetworkStatus = 'Disconnected' THEN 40
            ELSE 0
        END
        +
        CASE
            WHEN DefenderStatus = 'Disabled' THEN 30
            ELSE 0
        END
        +
        CASE
            WHEN FreeDiskPercent < 10 THEN 30
            WHEN FreeDiskPercent < 20 THEN 20
            ELSE 0
        END
        +
        CASE
            WHEN UptimeDays >= 50 THEN 10
            ELSE 0
        END
    ) AS RiskScore

FROM dbo.Endpoints

ORDER BY
    RiskScore DESC,
    EndpointID;


/* ============================================================
   02. ENDPOINT PRIORITY CLASSIFICATION
   ------------------------------------------------------------
   Converts the calculated risk score into an operational
   priority level for administrator review.
   
   Risk thresholds:
       50+  = Critical
       30+  = High
       20+  = Medium
       <20  = Low
   ============================================================ */

SELECT
    EndpointID,
    ComputerName,
    FreeDiskPercent,
    UptimeDays,
    NetworkStatus,
    DefenderStatus,
    BitLockerStatus,
    HealthStatus,
    HealthReason,

    (
        CASE
            WHEN NetworkStatus = 'Disconnected' THEN 40
            ELSE 0
        END
        +
        CASE
            WHEN DefenderStatus = 'Disabled' THEN 30
            ELSE 0
        END
        +
        CASE
            WHEN FreeDiskPercent < 10 THEN 30
            WHEN FreeDiskPercent < 20 THEN 20
            ELSE 0
        END
        +
        CASE
            WHEN UptimeDays >= 50 THEN 10
            ELSE 0
        END
    ) AS RiskScore,

    CASE
        WHEN
            (
                CASE WHEN NetworkStatus = 'Disconnected' THEN 40 ELSE 0 END
                +
                CASE WHEN DefenderStatus = 'Disabled' THEN 30 ELSE 0 END
                +
                CASE
                    WHEN FreeDiskPercent < 10 THEN 30
                    WHEN FreeDiskPercent < 20 THEN 20
                    ELSE 0
                END
                +
                CASE WHEN UptimeDays >= 50 THEN 10 ELSE 0 END
            ) >= 50
            THEN 'Critical'

        WHEN
            (
                CASE WHEN NetworkStatus = 'Disconnected' THEN 40 ELSE 0 END
                +
                CASE WHEN DefenderStatus = 'Disabled' THEN 30 ELSE 0 END
                +
                CASE
                    WHEN FreeDiskPercent < 10 THEN 30
                    WHEN FreeDiskPercent < 20 THEN 20
                    ELSE 0
                END
                +
                CASE WHEN UptimeDays >= 50 THEN 10 ELSE 0 END
            ) >= 30
            THEN 'High'

        WHEN
            (
                CASE WHEN NetworkStatus = 'Disconnected' THEN 40 ELSE 0 END
                +
                CASE WHEN DefenderStatus = 'Disabled' THEN 30 ELSE 0 END
                +
                CASE
                    WHEN FreeDiskPercent < 10 THEN 30
                    WHEN FreeDiskPercent < 20 THEN 20
                    ELSE 0
                END
                +
                CASE WHEN UptimeDays >= 50 THEN 10 ELSE 0 END
            ) >= 20
            THEN 'Medium'

        ELSE 'Low'
    END AS PriorityLevel

FROM dbo.Endpoints

ORDER BY
    RiskScore DESC,
    EndpointID;


/* ============================================================
   03. ADMINISTRATOR RECOMMENDED ACTION
   ------------------------------------------------------------
   Provides an operational recommendation based on the
   calculated endpoint risk score.
   ============================================================ */

SELECT
    EndpointID,
    ComputerName,
    FreeDiskPercent,
    UptimeDays,
    NetworkStatus,
    DefenderStatus,
    BitLockerStatus,
    HealthStatus,
    HealthReason,

    (
        CASE
            WHEN NetworkStatus = 'Disconnected' THEN 40
            ELSE 0
        END
        +
        CASE
            WHEN DefenderStatus = 'Disabled' THEN 30
            ELSE 0
        END
        +
        CASE
            WHEN FreeDiskPercent < 10 THEN 30
            WHEN FreeDiskPercent < 20 THEN 20
            ELSE 0
        END
        +
        CASE
            WHEN UptimeDays >= 50 THEN 10
            ELSE 0
        END
    ) AS RiskScore,

    CASE
        WHEN
            (
                CASE WHEN NetworkStatus = 'Disconnected' THEN 40 ELSE 0 END
                +
                CASE WHEN DefenderStatus = 'Disabled' THEN 30 ELSE 0 END
                +
                CASE
                    WHEN FreeDiskPercent < 10 THEN 30
                    WHEN FreeDiskPercent < 20 THEN 20
                    ELSE 0
                END
                +
                CASE WHEN UptimeDays >= 50 THEN 10 ELSE 0 END
            ) >= 50
            THEN 'Immediate investigation required'

        WHEN
            (
                CASE WHEN NetworkStatus = 'Disconnected' THEN 40 ELSE 0 END
                +
                CASE WHEN DefenderStatus = 'Disabled' THEN 30 ELSE 0 END
                +
                CASE
                    WHEN FreeDiskPercent < 10 THEN 30
                    WHEN FreeDiskPercent < 20 THEN 20
                    ELSE 0
                END
                +
                CASE WHEN UptimeDays >= 50 THEN 10 ELSE 0 END
            ) >= 30
            THEN 'Administrator attention required'

        WHEN
            (
                CASE WHEN NetworkStatus = 'Disconnected' THEN 40 ELSE 0 END
                +
                CASE WHEN DefenderStatus = 'Disabled' THEN 30 ELSE 0 END
                +
                CASE
                    WHEN FreeDiskPercent < 10 THEN 30
                    WHEN FreeDiskPercent < 20 THEN 20
                    ELSE 0
                END
                +
                CASE WHEN UptimeDays >= 50 THEN 10 ELSE 0 END
            ) >= 20
            THEN 'Monitor and schedule maintenance'

        ELSE 'No immediate action required'
    END AS RecommendedAction

FROM dbo.Endpoints

ORDER BY
    RiskScore DESC,
    EndpointID;


/* ============================================================
   04. ENDPOINT RISK AND REMEDIATION REPORT
   ------------------------------------------------------------
   Combines:
       - Risk score
       - Priority level
       - Recommended remediation
       
   Multiple endpoint issues are included in the remediation
   message when applicable.
   ============================================================ */

SELECT
    EndpointID,
    ComputerName,
    FreeDiskPercent,
    UptimeDays,
    NetworkStatus,
    DefenderStatus,
    BitLockerStatus,
    HealthStatus,
    HealthReason,

    -- Risk Score
    (
        CASE
            WHEN NetworkStatus = 'Disconnected' THEN 40
            ELSE 0
        END
        +
        CASE
            WHEN DefenderStatus = 'Disabled' THEN 30
            ELSE 0
        END
        +
        CASE
            WHEN FreeDiskPercent < 10 THEN 30
            WHEN FreeDiskPercent < 20 THEN 20
            ELSE 0
        END
        +
        CASE
            WHEN UptimeDays >= 50 THEN 10
            ELSE 0
        END
    ) AS RiskScore,

    -- Priority Level
    CASE
        WHEN
            (
                CASE WHEN NetworkStatus = 'Disconnected' THEN 40 ELSE 0 END
                +
                CASE WHEN DefenderStatus = 'Disabled' THEN 30 ELSE 0 END
                +
                CASE
                    WHEN FreeDiskPercent < 10 THEN 30
                    WHEN FreeDiskPercent < 20 THEN 20
                    ELSE 0
                END
                +
                CASE WHEN UptimeDays >= 50 THEN 10 ELSE 0 END
            ) >= 50
            THEN 'Critical'

        WHEN
            (
                CASE WHEN NetworkStatus = 'Disconnected' THEN 40 ELSE 0 END
                +
                CASE WHEN DefenderStatus = 'Disabled' THEN 30 ELSE 0 END
                +
                CASE
                    WHEN FreeDiskPercent < 10 THEN 30
                    WHEN FreeDiskPercent < 20 THEN 20
                    ELSE 0
                END
                +
                CASE WHEN UptimeDays >= 50 THEN 10 ELSE 0 END
            ) >= 30
            THEN 'High'

        WHEN
            (
                CASE WHEN NetworkStatus = 'Disconnected' THEN 40 ELSE 0 END
                +
                CASE WHEN DefenderStatus = 'Disabled' THEN 30 ELSE 0 END
                +
                CASE
                    WHEN FreeDiskPercent < 10 THEN 30
                    WHEN FreeDiskPercent < 20 THEN 20
                    ELSE 0
                END
                +
                CASE WHEN UptimeDays >= 50 THEN 10 ELSE 0 END
            ) >= 20
            THEN 'Medium'

        ELSE 'Low'
    END AS PriorityLevel,

    -- Recommended Remediation
    CONCAT(
        CASE
            WHEN NetworkStatus = 'Disconnected'
                THEN 'Investigate network connectivity; '
            ELSE ''
        END,

        CASE
            WHEN DefenderStatus = 'Disabled'
                THEN 'Enable Microsoft Defender; '
            ELSE ''
        END,

        CASE
            WHEN FreeDiskPercent < 10
                THEN 'Urgently free disk space; '
            WHEN FreeDiskPercent < 20
                THEN 'Free disk space; '
            ELSE ''
        END,

        CASE
            WHEN UptimeDays >= 50
                THEN 'Schedule system restart; '
            ELSE ''
        END,

        CASE
            WHEN NetworkStatus = 'Connected'
                 AND DefenderStatus = 'Enabled'
                 AND FreeDiskPercent >= 20
                 AND UptimeDays < 50
                THEN 'No immediate remediation required'
            ELSE ''
        END
    ) AS RecommendedRemediation

FROM dbo.Endpoints

ORDER BY
    RiskScore DESC,
    EndpointID;


/* ============================================================
   05. ADMINISTRATOR EXECUTIVE SUMMARY
   ------------------------------------------------------------
   Provides a high-level operational view of endpoint health,
   security, connectivity, storage, and encryption status.
   ============================================================ */

SELECT
    COUNT(*) AS TotalEndpoints,

    SUM(CASE
        WHEN HealthStatus = 'Healthy' THEN 1
        ELSE 0
    END) AS Healthy,

    SUM(CASE
        WHEN HealthStatus = 'At Risk' THEN 1
        ELSE 0
    END) AS AtRisk,

    SUM(CASE
        WHEN HealthStatus = 'Critical' THEN 1
        ELSE 0
    END) AS Critical,

    SUM(CASE
        WHEN NetworkStatus = 'Disconnected' THEN 1
        ELSE 0
    END) AS NetworkDisconnected,

    SUM(CASE
        WHEN DefenderStatus = 'Disabled' THEN 1
        ELSE 0
    END) AS DefenderDisabled,

    SUM(CASE
        WHEN FreeDiskPercent < 20 THEN 1
        ELSE 0
    END) AS LowDisk,

    SUM(CASE
        WHEN BitLockerStatus = 'Unknown' THEN 1
        ELSE 0
    END) AS BitLockerUnknown,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN HealthStatus = 'Healthy' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS HealthyPercentage

FROM dbo.Endpoints;


/* ============================================================
   06. WINDOWS BUILD DISTRIBUTION
   ------------------------------------------------------------
   Identifies the number of endpoints running each Windows
   build and supports endpoint environment analysis.
   ============================================================ */

SELECT
    WindowsBuild,
    COUNT(*) AS EndpointCount

FROM dbo.Endpoints

GROUP BY
    WindowsBuild

ORDER BY
    EndpointCount DESC;


/* ============================================================
   07. TOP 15 PRIORITY ENDPOINTS
   ------------------------------------------------------------
   Returns the highest-priority endpoints for administrator
   investigation and remediation.
   ============================================================ */

SELECT TOP 15
    EndpointID,
    ComputerName,
    WindowsBuild,
    FreeDiskPercent,
    UptimeDays,
    NetworkStatus,
    DefenderStatus,
    BitLockerStatus,
    HealthStatus,

    (
        CASE
            WHEN NetworkStatus = 'Disconnected' THEN 40
            ELSE 0
        END
        +
        CASE
            WHEN DefenderStatus = 'Disabled' THEN 30
            ELSE 0
        END
        +
        CASE
            WHEN FreeDiskPercent < 10 THEN 30
            WHEN FreeDiskPercent < 20 THEN 20
            ELSE 0
        END
        +
        CASE
            WHEN UptimeDays >= 50 THEN 10
            ELSE 0
        END
    ) AS RiskScore

FROM dbo.Endpoints

ORDER BY
    RiskScore DESC,
    EndpointID;


/* ============================================================
   08. ADMINISTRATOR REMEDIATION REPORT
   ------------------------------------------------------------
   Identifies priority endpoints and provides a direct
   remediation recommendation for each endpoint.
   ============================================================ */

SELECT TOP 15
    EndpointID,
    ComputerName,
    HealthStatus,
    NetworkStatus,
    DefenderStatus,
    FreeDiskPercent,
    UptimeDays,

    (
        CASE
            WHEN NetworkStatus = 'Disconnected' THEN 40
            ELSE 0
        END
        +
        CASE
            WHEN DefenderStatus = 'Disabled' THEN 30
            ELSE 0
        END
        +
        CASE
            WHEN FreeDiskPercent < 10 THEN 30
            WHEN FreeDiskPercent < 20 THEN 20
            ELSE 0
        END
        +
        CASE
            WHEN UptimeDays >= 50 THEN 10
            ELSE 0
        END
    ) AS RiskScore,

    CASE
        WHEN NetworkStatus = 'Disconnected'
             AND DefenderStatus = 'Disabled'
            THEN 'Restore network connectivity and enable Microsoft Defender'

        WHEN NetworkStatus = 'Disconnected'
            THEN 'Investigate network connectivity'

        WHEN DefenderStatus = 'Disabled'
            THEN 'Enable Microsoft Defender and verify security status'

        WHEN FreeDiskPercent < 10
            THEN 'Urgently free disk space'

        WHEN FreeDiskPercent < 20
            THEN 'Free disk space and monitor storage'

        WHEN UptimeDays >= 50
            THEN 'Schedule system restart'

        ELSE 'No immediate remediation required'
    END AS RecommendedAction

FROM dbo.Endpoints

ORDER BY
    RiskScore DESC,
    EndpointID;


/* ============================================================
   09. ADMINISTRATOR WORK QUEUE
   ------------------------------------------------------------
   Groups endpoints into operational work categories.
   
   Note:
   Each endpoint is assigned to the first matching category
   based on the CASE evaluation order.
   ============================================================ */

SELECT
    CASE
        WHEN NetworkStatus = 'Disconnected'
            THEN 'Network Connectivity'

        WHEN DefenderStatus = 'Disabled'
            THEN 'Microsoft Defender'

        WHEN FreeDiskPercent < 10
            THEN 'Critical Disk Space'

        WHEN FreeDiskPercent < 20
            THEN 'Low Disk Space'

        WHEN UptimeDays >= 50
            THEN 'Long Uptime / Restart Required'

        ELSE 'No Immediate Action'
    END AS WorkCategory,

    COUNT(*) AS EndpointCount

FROM dbo.Endpoints

GROUP BY
    CASE
        WHEN NetworkStatus = 'Disconnected'
            THEN 'Network Connectivity'

        WHEN DefenderStatus = 'Disabled'
            THEN 'Microsoft Defender'

        WHEN FreeDiskPercent < 10
            THEN 'Critical Disk Space'

        WHEN FreeDiskPercent < 20
            THEN 'Low Disk Space'

        WHEN UptimeDays >= 50
            THEN 'Long Uptime / Restart Required'

        ELSE 'No Immediate Action'
    END

ORDER BY
    EndpointCount DESC;


/* ============================================================
   10. ADMINISTRATOR ENDPOINT WORK LIST
   ------------------------------------------------------------
   Produces an actionable endpoint-level work list for
   troubleshooting and maintenance.
   ============================================================ */

SELECT
    EndpointID,
    ComputerName,
    NetworkStatus,
    DefenderStatus,
    FreeDiskPercent,
    UptimeDays,
    WindowsBuild,

    CASE
        WHEN NetworkStatus = 'Disconnected'
            THEN 'Investigate network connectivity'

        WHEN DefenderStatus = 'Disabled'
            THEN 'Enable Microsoft Defender and verify security status'

        WHEN FreeDiskPercent < 10
            THEN 'Urgently free disk space'

        WHEN FreeDiskPercent < 20
            THEN 'Free disk space'

        WHEN UptimeDays >= 50
            THEN 'Schedule system restart'

        ELSE 'No Immediate Action'
    END AS RecommendedAction

FROM dbo.Endpoints

WHERE
       NetworkStatus = 'Disconnected'
    OR DefenderStatus = 'Disabled'
    OR FreeDiskPercent < 20
    OR UptimeDays >= 50

ORDER BY
    CASE
        WHEN NetworkStatus = 'Disconnected' THEN 1
        WHEN DefenderStatus = 'Disabled' THEN 2
        WHEN FreeDiskPercent < 10 THEN 3
        WHEN FreeDiskPercent < 20 THEN 4
        WHEN UptimeDays >= 50 THEN 5
        ELSE 6
    END,
    FreeDiskPercent ASC;


/* ============================================================
   11. ENDPOINT MANAGEMENT EXECUTIVE SUMMARY
   ------------------------------------------------------------
   Provides a focused summary of connectivity, endpoint
   security, storage capacity, and system uptime.
   ============================================================ */

SELECT
    COUNT(*) AS TotalEndpoints,

    SUM(CASE
        WHEN NetworkStatus = 'Connected' THEN 1
        ELSE 0
    END) AS ConnectedEndpoints,

    SUM(CASE
        WHEN NetworkStatus = 'Disconnected' THEN 1
        ELSE 0
    END) AS DisconnectedEndpoints,

    SUM(CASE
        WHEN DefenderStatus = 'Enabled' THEN 1
        ELSE 0
    END) AS DefenderEnabled,

    SUM(CASE
        WHEN DefenderStatus = 'Disabled' THEN 1
        ELSE 0
    END) AS DefenderDisabled,

    SUM(CASE
        WHEN FreeDiskPercent < 10 THEN 1
        ELSE 0
    END) AS CriticalDiskSpace,

    SUM(CASE
        WHEN FreeDiskPercent >= 10
             AND FreeDiskPercent < 20 THEN 1
        ELSE 0
    END) AS LowDiskSpace,

    SUM(CASE
        WHEN UptimeDays >= 50 THEN 1
        ELSE 0
    END) AS LongUptimeEndpoints

FROM dbo.Endpoints;


/* ============================================================
   12. ENDPOINT RISK CLASSIFICATION
   ------------------------------------------------------------
   Classifies endpoints according to connectivity, security,
   storage, and uptime conditions.
   ============================================================ */

SELECT
    EndpointID,
    ComputerName,
    NetworkStatus,
    DefenderStatus,
    FreeDiskPercent,
    UptimeDays,
    WindowsBuild,

    CASE
        WHEN NetworkStatus = 'Disconnected'
             OR DefenderStatus = 'Disabled'
             OR FreeDiskPercent < 10
            THEN 'Critical'

        WHEN FreeDiskPercent < 20
             OR UptimeDays >= 50
            THEN 'High Risk'

        WHEN UptimeDays >= 30
            THEN 'Moderate Risk'

        ELSE 'Healthy'
    END AS RiskLevel

FROM dbo.Endpoints

ORDER BY
    CASE
        WHEN NetworkStatus = 'Disconnected'
             OR DefenderStatus = 'Disabled'
             OR FreeDiskPercent < 10
            THEN 1

        WHEN FreeDiskPercent < 20
             OR UptimeDays >= 50
            THEN 2

        WHEN UptimeDays >= 30
            THEN 3

        ELSE 4
    END,
    FreeDiskPercent ASC;


/* ============================================================
   13. RISK LEVEL SUMMARY
   ------------------------------------------------------------
   Provides the number of endpoints in each risk category.
   ============================================================ */

SELECT
    CASE
        WHEN NetworkStatus = 'Disconnected'
             OR DefenderStatus = 'Disabled'
             OR FreeDiskPercent < 10
            THEN 'Critical'

        WHEN FreeDiskPercent < 20
             OR UptimeDays >= 50
            THEN 'High Risk'

        WHEN UptimeDays >= 30
            THEN 'Moderate Risk'

        ELSE 'Healthy'
    END AS RiskLevel,

    COUNT(*) AS EndpointCount

FROM dbo.Endpoints

GROUP BY
    CASE
        WHEN NetworkStatus = 'Disconnected'
             OR DefenderStatus = 'Disabled'
             OR FreeDiskPercent < 10
            THEN 'Critical'

        WHEN FreeDiskPercent < 20
             OR UptimeDays >= 50
            THEN 'High Risk'

        WHEN UptimeDays >= 30
            THEN 'Moderate Risk'

        ELSE 'Healthy'
    END

ORDER BY
    EndpointCount DESC;


/* ============================================================
   14. WINDOWS BUILD DISTRIBUTION
   ------------------------------------------------------------
   Calculates the percentage of endpoints running each
   Windows build.
   ============================================================ */

SELECT
    WindowsBuild,
    COUNT(*) AS EndpointCount,

    CAST(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM dbo.Endpoints)
        AS DECIMAL(5,2)
    ) AS PercentageOfEndpoints

FROM dbo.Endpoints

GROUP BY
    WindowsBuild

ORDER BY
    EndpointCount DESC;


/* ============================================================
   15. WINDOWS BUILD VS. RISK LEVEL
   ------------------------------------------------------------
   Compares endpoint risk levels across Windows builds to
   support system administration and environment analysis.
   ============================================================ */

SELECT
    WindowsBuild,

    CASE
        WHEN NetworkStatus = 'Disconnected'
             OR DefenderStatus = 'Disabled'
             OR FreeDiskPercent < 10
            THEN 'Critical'

        WHEN FreeDiskPercent < 20
             OR UptimeDays >= 50
            THEN 'High Risk'

        WHEN UptimeDays >= 30
            THEN 'Moderate Risk'

        ELSE 'Healthy'
    END AS RiskLevel,

    COUNT(*) AS EndpointCount

FROM dbo.Endpoints

GROUP BY
    WindowsBuild,

    CASE
        WHEN NetworkStatus = 'Disconnected'
             OR DefenderStatus = 'Disabled'
             OR FreeDiskPercent < 10
            THEN 'Critical'

        WHEN FreeDiskPercent < 20
             OR UptimeDays >= 50
            THEN 'High Risk'

        WHEN UptimeDays >= 30
            THEN 'Moderate Risk'

        ELSE 'Healthy'
    END

ORDER BY
    WindowsBuild,
    EndpointCount DESC;


/* ============================================================
   16. TOP 10 PRIORITY ENDPOINTS
   ------------------------------------------------------------
   Identifies the ten endpoints requiring the highest level
   of administrator attention based on endpoint conditions.
   ============================================================ */

SELECT TOP 10
    EndpointID,
    ComputerName,
    NetworkStatus,
    DefenderStatus,
    FreeDiskPercent,
    UptimeDays,
    WindowsBuild,

    CASE
        WHEN NetworkStatus = 'Disconnected'
             OR DefenderStatus = 'Disabled'
             OR FreeDiskPercent < 10
            THEN 'Critical'

        WHEN FreeDiskPercent < 20
             OR UptimeDays >= 50
            THEN 'High Risk'

        WHEN UptimeDays >= 30
            THEN 'Moderate Risk'

        ELSE 'Healthy'
    END AS RiskLevel,

    CASE
        WHEN NetworkStatus = 'Disconnected'
            THEN 'Investigate network connectivity'

        WHEN DefenderStatus = 'Disabled'
            THEN 'Enable Microsoft Defender'

        WHEN FreeDiskPercent < 10
            THEN 'Urgently free disk space'

        WHEN FreeDiskPercent < 20
            THEN 'Free disk space'

        WHEN UptimeDays >= 50
            THEN 'Schedule system restart'

        ELSE 'No Immediate Action'
    END AS RecommendedAction

FROM dbo.Endpoints

ORDER BY
    CASE
        WHEN NetworkStatus = 'Disconnected'
             OR DefenderStatus = 'Disabled'
             OR FreeDiskPercent < 10
            THEN 1

        WHEN FreeDiskPercent < 20
             OR UptimeDays >= 50
            THEN 2

        WHEN UptimeDays >= 30
            THEN 3

        ELSE 4
    END,
    FreeDiskPercent ASC;
