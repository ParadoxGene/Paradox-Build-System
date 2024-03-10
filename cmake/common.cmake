macro(paradox_set_global varname value)
    set_property(GLOBAL PROPERTY PARADOX_GLOBAL_${varname}_PROPERTY ${value})
endmacro()

macro(paradox_get_global varname)
    get_property(PARADOX_GLOBAL_${varname} GLOBAL PROPERTY PARADOX_GLOBAL_${varname}_PROPERTY)
endmacro()