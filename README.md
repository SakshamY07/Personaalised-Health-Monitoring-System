# Personalized Health Monitoring System

Foundational Java web application skeleton for an academic Core Java, OOP, JDBC, and Servlet review.

## Quick start

1. Create the MySQL schema by running [`schema.sql`](./schema.sql).
2. Configure `DB_URL`, `DB_USER`, and `DB_PASSWORD` as environment variables or JVM system properties.
3. Build the WAR with Maven: `mvn clean package`.
4. Deploy `target/personalized-health-monitoring-system-1.0.0-SNAPSHOT.war` to a Servlet 4/Tomcat 9 server.
5. Open `/dashboard.html`; the dashboard calls `/api/metrics?userId=1`.

The POST endpoint accepts JSON such as:

```json
{"userId":1,"heartRate":72,"spo2":98.5,"steps":6840,"sleepHours":7.5}
```

The sample password hash in the seed data is illustrative only and must be replaced by a real password-hashing flow in a production system.
