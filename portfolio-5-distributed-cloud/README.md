# Portfolio 5: Distributed and Cloud Database Exercise

## Case study context
The glasses store needs its order and stock database to stay available if one
server fails, and to cope with read-heavy traffic (customers browsing frames)
without slowing down order processing.

## Setup: MySQL primary-replica replication (Docker)
`docker-compose.yml` runs two MySQL 8 servers:
- `mysql_primary` (port 3307): accepts writes, writes a binary log.
- `mysql_replica` (port 3308): copies every change from the primary using
  GTID-based replication.

Steps carried out:
1. Started both servers with `docker compose up -d`.
2. Created a replication user on the primary.
3. Pointed the replica at the primary with `CHANGE REPLICATION SOURCE TO ...`
   and started it with `START REPLICA`.
4. Checked `SHOW REPLICA STATUS`: both `Replica_IO_Running` and
   `Replica_SQL_Running` were `Yes`.

![Replica status](screenshots/01-replica-status.png)

## Evidence: replication works
A database, table and order row were created on the primary and then read
from the replica, showing the data was copied automatically.

![Replication test](screenshots/02-replication-test.png)

## Evidence: replica is read-only
With `super_read_only` switched on, an INSERT on the replica was rejected,
so all writes must go through the primary and the two copies cannot diverge.

![Read-only replica](screenshots/03-readonly.png)

## Evidence: failover
The primary was stopped (simulating a crash). The replica was promoted by
stopping replication and turning read-only off, after which it accepted
writes. The data copied earlier was still available, which shows the benefit
of replication for availability. In this setup promotion is manual; in
production it is automated (for example MySQL InnoDB Cluster or a managed
cloud service).

![Failover](screenshots/04-failover.png)

## Discussion

### Replication and availability
Replication keeps a live copy of the data on a second server. If the primary
fails, the replica can take over, so the shop keeps taking orders. Reads such
as product browsing can also be sent to the replica to reduce load on the
primary.

### Consistency trade-off
Replication is asynchronous by default, so the replica can lag slightly
behind the primary. A customer reading from the replica could briefly see
old stock. Because of this, stock checks and payments must always use the
primary (strong consistency), while the product catalogue and reviews can
tolerate small delays (eventual consistency). This reflects the CAP theorem:
during a network partition a system must choose between consistency and
availability.

### Sharding
If orders grow beyond what one server can handle, the `orders` table can be
split across servers (sharding). A good shard key is `customer_id` using a
hash, because it spreads writes evenly and keeps one customer's orders
together. `order_date` would be a poor key because all new orders would hit
the same shard. Costs of sharding are cross-shard joins and distributed
transactions, which is why it is only used when one server is no longer enough.

### Cloud deployment
Instead of running servers myself, the database could be deployed on a managed
service such as Amazon RDS or Aurora for MySQL, Azure Database for MySQL, or
Google Cloud SQL. These provide automatic backups, multi-zone failover and
read replicas, at the cost of monthly fees and less low-level control. For a
small online shop a managed database reduces the operational work of
patching, backups and failover.

## How to reproduce
1. `cd portfolio-5-distributed-cloud && docker compose up -d`
2. Create the replication user on the primary and configure the replica
   (commands recorded in the screenshots above).
