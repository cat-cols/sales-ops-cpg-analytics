-- Project 2: Quarterly Data Collection + QA/QC System
-- Purpose: track expected source submissions from intake through certification

create table if not exists ops.intake_submission_log (
    submission_id        bigint generated always as identity primary key,
    quarter_id           text not null,
    department_name      text not null,
    source_file_name     text not null,
    template_version     text,
    submitted_by         text,
    submitted_at         timestamp,
    expected_by          timestamp,
    received_flag        boolean not null default false,
    schema_valid_flag    boolean,
    qa_status            text not null default 'pending',
    certified_flag       boolean not null default false,
    notes                text,
    created_at           timestamp not null default current_timestamp,
    updated_at           timestamp not null default current_timestamp,

    constraint chk_intake_qa_status
        check (qa_status in ('pending', 'failed', 'passed', 'certified'))
);

create index if not exists ix_intake_submission_log_quarter
    on ops.intake_submission_log (quarter_id);

create index if not exists ix_intake_submission_log_department
    on ops.intake_submission_log (department_name);

create index if not exists ix_intake_submission_log_source_file
    on ops.intake_submission_log (source_file_name);

create unique index if not exists ux_intake_submission_log_quarter_file
    on ops.intake_submission_log (quarter_id, source_file_name);