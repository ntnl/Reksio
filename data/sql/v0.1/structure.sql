CREATE TABLE reksio_Metadata (
    property    VARCHAR(64),
    value       VARCHAR(256)
);

###

CREATE TABLE reksio_Repository (
    id      INT,

    name    VARCHAR(128),
    vcs     VARCHAR(32),
    uri     VARCHAR(1024)
);

CREATE TABLE reksio_Build (
    id              INT,
    repository_id   INT,

    name            VARCHAR(128),
    build_command   VARCHAR(1024),
    frequency       VARCHAR(32),
        -- EACH - run this build for each revision/commit
        -- RECENT - run always on most recent revision/commit (possibly skipping commits)
        -- HOURLY - run not often, then once per hour (on recent commit, unless already build)
        -- DAILY - run once per day (on most recent commit, unless already build)

    result_type     VARCHAR(32)
        -- NONE - ignore the result (build always positive).
        -- EXITCODE - buld was successful if command's exit code was zero.
        -- POD - parse output as POD, and judge results by that.
);

CREATE TABLE reksio_Revision (
    id              INT,
    repository_id   INT,

    commit_id           VARCHAR(128),
    parent_commit_id    VARCHAR(128),

    was_tested          INT
);

CREATE TABLE reksio_Result (
    id              INT,
    revision_id     INT,
    build_id        INT,

    status  CHAR(1),
        -- N - New (scheduled for execution)
        -- R - Running
        -- F - Finished
        -- E - Finished with error

    date_queued         DATETIME,
    date_start          DATETIME,
    date_finish         DATETIME,
    total_tests_count   INT,
    total_cases_count   INT,
    failed_tests_count  INT,
    failed_cases_count  INT
);

