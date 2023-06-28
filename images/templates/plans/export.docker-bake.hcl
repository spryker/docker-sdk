{% import "images/templates/plans/tag." ~ buildDestination ~ "." ~ tagMode ~ ".twig" as tagMacro %}
group "default" {
    targets = [
        "application",
        "frontend",
        "pipeline",
        "jenkins",
    ]
}

{% include "images/templates/plans/common.docker-bake.hcl" with { folder: 'export'} %}

target "application" {
    inherits = ["_common"]
    target = "application"
    tags = [
{% for application in _applications %}
        {{ tagMacro.tagApplication(application, ",\n        ") | spaceless }}
{% endfor %}
    ]
}

target "frontend" {
    inherits = ["_common"]
    target = "frontend"
    tags = [
        {{ tagMacro.tagService("frontend", ",\n        ") | spaceless }}
    ]
}

target "pipeline" {
    inherits = ["_common"]
    target = "pipeline"
    tags = [
        {{ tagMacro.tagService("pipeline", ",\n        ") | spaceless }}
    ]
}

target "jenkins" {
    inherits = ["_common"]
    target = "jenkins"
    tags = [
       {{ tagMacro.tagService("jenkins", ",\n        ") | spaceless }}
    ]
}
