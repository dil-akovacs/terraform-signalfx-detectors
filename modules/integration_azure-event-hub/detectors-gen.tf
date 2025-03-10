resource "signalfx_detector" "throttled_requests" {
  name = format("%s %s", local.detector_name_prefix, "Azure Event Hub throttled requests")

  authorized_writer_teams = var.authorized_writer_teams
  teams                   = try(coalescelist(var.teams, var.authorized_writer_teams), null)
  tags                    = compact(concat(local.common_tags, local.tags, var.extra_tags))

  viz_options {
    label        = "signal"
    value_suffix = "%"
  }

  program_text = <<-EOF
    base_filtering = filter('resource_type', 'Microsoft.EventHub/namespaces') and filter('primary_aggregation_type', 'true')
    A = data('ThrottledRequests', filter=base_filtering and ${module.filtering.signalflow})${var.throttled_requests_aggregation_function}${var.throttled_requests_transformation_function}
    B = data('IncomingRequests', filter=base_filtering and ${module.filtering.signalflow})${var.throttled_requests_aggregation_function}${var.throttled_requests_transformation_function}
    signal = (A/B).scale(100).fill(0).publish('signal')
    detect(when(signal > ${var.throttled_requests_threshold_critical}, lasting=%{if var.throttled_requests_lasting_duration_critical == null}None%{else}'${var.throttled_requests_lasting_duration_critical}'%{endif}, at_least=${var.throttled_requests_at_least_percentage_critical})).publish('CRIT')
    detect(when(signal > ${var.throttled_requests_threshold_major}, lasting=%{if var.throttled_requests_lasting_duration_major == null}None%{else}'${var.throttled_requests_lasting_duration_major}'%{endif}, at_least=${var.throttled_requests_at_least_percentage_major}) and (not when(signal > ${var.throttled_requests_threshold_critical}, lasting=%{if var.throttled_requests_lasting_duration_critical == null}None%{else}'${var.throttled_requests_lasting_duration_critical}'%{endif}, at_least=${var.throttled_requests_at_least_percentage_critical}))).publish('MAJOR')
    detect(when(signal > ${var.throttled_requests_threshold_warning}, lasting=%{if var.throttled_requests_lasting_duration_warning == null}None%{else}'${var.throttled_requests_lasting_duration_warning}'%{endif}, at_least=${var.throttled_requests_at_least_percentage_warning}) and (not when(signal > ${var.throttled_requests_threshold_major}, lasting=%{if var.throttled_requests_lasting_duration_major == null}None%{else}'${var.throttled_requests_lasting_duration_major}'%{endif}, at_least=${var.throttled_requests_at_least_percentage_major}))).publish('WARN')
EOF

  rule {
    description           = "is too high > ${var.throttled_requests_threshold_critical}%"
    severity              = "Critical"
    detect_label          = "CRIT"
    disabled              = coalesce(var.throttled_requests_disabled_critical, var.throttled_requests_disabled, var.detectors_disabled)
    notifications         = coalescelist(lookup(var.throttled_requests_notifications, "critical", []), var.notifications.critical)
    runbook_url           = try(coalesce(var.throttled_requests_runbook_url, var.runbook_url), "")
    tip                   = var.throttled_requests_tip
    parameterized_subject = var.message_subject == "" ? local.rule_subject : var.message_subject
    parameterized_body    = var.message_body == "" ? local.rule_body : var.message_body
  }

  rule {
    description           = "is too high > ${var.throttled_requests_threshold_major}%"
    severity              = "Major"
    detect_label          = "MAJOR"
    disabled              = coalesce(var.throttled_requests_disabled_major, var.throttled_requests_disabled, var.detectors_disabled)
    notifications         = coalescelist(lookup(var.throttled_requests_notifications, "major", []), var.notifications.major)
    runbook_url           = try(coalesce(var.throttled_requests_runbook_url, var.runbook_url), "")
    tip                   = var.throttled_requests_tip
    parameterized_subject = var.message_subject == "" ? local.rule_subject : var.message_subject
    parameterized_body    = var.message_body == "" ? local.rule_body : var.message_body
  }

  rule {
    description           = "is too high > ${var.throttled_requests_threshold_warning}%"
    severity              = "Warning"
    detect_label          = "WARN"
    disabled              = coalesce(var.throttled_requests_disabled_warning, var.throttled_requests_disabled, var.detectors_disabled)
    notifications         = coalescelist(lookup(var.throttled_requests_notifications, "warning", []), var.notifications.warning)
    runbook_url           = try(coalesce(var.throttled_requests_runbook_url, var.runbook_url), "")
    tip                   = var.throttled_requests_tip
    parameterized_subject = var.message_subject == "" ? local.rule_subject : var.message_subject
    parameterized_body    = var.message_body == "" ? local.rule_body : var.message_body
  }
}

