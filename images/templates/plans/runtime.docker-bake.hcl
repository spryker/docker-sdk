{% import "images/templates/plans/tag." ~ buildDestination ~ "." ~ tagMode ~ ".twig" as tagMacro %}
group "default" {
    targets = [
        "application",
        "frontend",
        "cli",
        "gateway",
    ]
}

{% include "images/templates/plans/common.docker-bake.hcl" with { folder }  %}

target "application" {
    inherits = ["_common"]
    target = "application-dev"
    tags = [
{% for application in _applications %}
        {{ tagMacro.tagApplication(application, ",\n        ") | spaceless }}
{% endfor %}
    ]
}

target "frontend" {
    inherits = ["_common"]
    target = "frontend-dev"
    tags = [
        {{ tagMacro.tagService("run_frontend", ",\n        ") | spaceless }}
    ]
}

target "cli" {
    inherits = ["_common"]
    target = "cli"
    tags = [
        {{ tagMacro.tagService("run_cli", ",\n        ") | spaceless }}
    ]
}

target "gateway" {
    inherits = ["_common"]
    target = "gateway"
    tags = [
       {{ tagMacro.tagService("gateway", ",\n        ") | spaceless }}
    ]
}
