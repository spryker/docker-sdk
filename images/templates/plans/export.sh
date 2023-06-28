{% import "images/templates/plans/tag." ~ buildDestination ~ "." ~ tagMode ~ ".twig" as tagMacro %}
# expects TARGET_TAG to be set
local -a IMAGE_TAGS=( \
{% for application in _applications %}
'local IMAGE="{{ application }}"; local -a TAGS=({{ tagMacro.tagApplication(application, " ") }})' \
{% endfor %}
'local IMAGE="frontend"; local -a TAGS=({{ tagMacro.tagService("frontend", " ") }})' \
'local IMAGE="pipeline"; local -a TAGS=({{ tagMacro.tagService("pipeline", " ") }})' \
'local IMAGE="jenkins"; local -a TAGS=({{ tagMacro.tagService("jenkins", " ") }})' \
)

local -a TARGET_TAGS=( \
'local TARGET="application"; local -a TAGS=({% for application in _applications %}{{ tagMacro.tagApplication(application, " ") }}{{ ' ' }}{% endfor %})' \
'local TARGET="frontend"; local -a TAGS=({{ tagMacro.tagService("frontend", " ") }})' \
'local TARGET="pipeline"; local -a TAGS=({{ tagMacro.tagService("pipeline", " ") }})' \
'local TARGET="jenkins"; local -a TAGS=({{ tagMacro.tagService("jenkins", " ") }})' \
)
