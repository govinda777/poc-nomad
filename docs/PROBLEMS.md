# Problems & Solutions

## 1. Data Conflict Resolution
**Problem:** Active-Active writes can lead to ID collisions.
**Solution:** Last-Write-Wins (LWW) based on timestamp, or using UUIDs. In this POC, we demonstrate the conflict by allowing collisions or using LWW triggers.

## 2. Network Partitions
**Problem:** Split-brain scenarios where both sides accept writes.
**Solution:** Application logic must handle eventual consistency. We use Redis queues to buffer messages when the link is down.

## 3. Latency
**Problem:** Cross-cloud replication lag.
**Solution:** Asynchronous replication for higher availability (AP over CP).
