#include <hwloc.h>

int hwloc_get_obj_type(hwloc_obj_t obj)
{
  return obj->type;
}

unsigned int hwloc_get_obj_os_index(hwloc_obj_t obj)
{
  return obj->os_index;
}

char* hwloc_get_obj_name(hwloc_obj_t obj)
{
  return obj->name;
}

unsigned int hwloc_get_obj_depth(hwloc_obj_t obj)
{
  return obj->depth;
}

unsigned int hwloc_get_obj_logical_index(hwloc_obj_t obj)
{
  return obj->logical_index;
}

int hwloc_get_obj_os_level(hwloc_obj_t obj)
{
  return obj->os_level;
}

unsigned int hwloc_get_obj_arity(hwloc_obj_t obj)
{
  return obj->arity;
}

hwloc_obj_t* hwloc_get_obj_children(hwloc_obj_t obj)
{
  return obj->children;
}
