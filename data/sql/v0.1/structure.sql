CREATE TABLE reksio_Metadata (
    property    VARCHAR(64),
    value       VARCHAR(256)
);

CREATE TABLE reksio_Repository (
    id      INTEGER PRIMARY KEY,

    name    VARCHAR(128),
    vcs     VARCHAR(32),
    uri     VARCHAR(1024)
);
CREATE UNIQUE INDEX reksio_Repository_name ON reksio_Repository (name);

CREATE TABLE reksio_Build (
    id              INTEGER PRIMARY KEY,
    repository_id   INTEGER,

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
        -- TAP - parse output as TAP, and judge results by that.
);
CREATE UNIQUE INDEX reksio_Build_name ON reksio_Build (name, repository_id);

CREATE TABLE reksio_Revision (
    id              INTEGER PRIMARY KEY,
    repository_id   INTEGER,

    commit_id           VARCHAR(128),
    parent_commit_id    VARCHAR(128),
    
    timestamp INT,
    commiter  VARCHAR(250),

    message TEXT,

    status CHAR(1)
        -- N - new (not touched)
        -- S - all mandatory builds for this revision have been scheduled
        -- B - all scheduled builds complete
);
CREATE UNIQUE INDEX reksio_Revision_commit_id ON reksio_Revision (repository_id, commit_id);

CREATE TABLE reksio_Result (
    id              INTEGER PRIMARY KEY,
    revision_id     INTEGER,
    build_id        INTEGER,

    status CHAR(1),
        -- N - New (scheduled for execution)
        -- R - Running
        -- P - Finished (Positive)
        -- N - Finished (Negative)
        -- E - Internal error happened during the build

    date_queued DATETIME,
    date_start  DATETIME,
    date_finish DATETIME,

    total_tests_count  INTEGER,
    total_cases_count  INTEGER,
    failed_tests_count INTEGER,
    failed_cases_count INTEGER
);

