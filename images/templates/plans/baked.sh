{% import "images/templates/plans/tag." ~ buildDestination ~ "." ~ tagMode ~ ".twig" as tagMacro %}
# expects TARGET_TAG to be set
local -a IMAGE_TAGS=( \
{% for application in _applications %}
'local IMAGE="{{ application }}"; local -a TAGS=({{ tagMacro.tagApplication(application, " ") }})' \
{% endfor %}
'local IMAGE="frontend"; local -a TAGS=({{ tagMacro.tagService("run_frontend", " ") }})' \
'local IMAGE="cli"; local -a TAGS=({{ tagMacro.tagService("run_cli", " ") }})' \
'local IMAGE="gateway"; local -a TAGS=({{ tagMacro.tagService("gateway", " ") }})' \
)

local -a TARGET_TAGS=( \
'local TARGET="application-dev"; local -a TAGS=({% for application in _applications %}{{ tagMacro.tagApplication(application, " ") }}{{ ' ' }}{% endfor %})' \
'local TARGET="frontend-dev"; local -a TAGS=({{ tagMacro.tagService("run_frontend", " ") }})' \
'local TARGET="cli"; local -a TAGS=({{ tagMacro.tagService("run_cli", " ") }})' \
'local TARGET="gateway"; local -a TAGS=({{ tagMacro.tagService("gateway", " ") }})' \
)
