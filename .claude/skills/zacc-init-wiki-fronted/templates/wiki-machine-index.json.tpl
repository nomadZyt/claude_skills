{
  "project": "{project_name}",
  "type": "{project_type}",
  "language": "{language}",
  "generated": "{ISO-8601}",
  "last_updated": "{ISO-8601}",
  "node_count": {N},
  "nodes": {
    "{id}": {
      "title": "{title}",
      "type": "{type}",
      "path": "{path}",
      "previous_paths": ["{previous_path}"],
      "aliases": ["{alias}"],
      "tags": ["{tag}"],
      "module_kind": "{module_kind}",
      "layer": "{layer}",
      "exports": ["{export_name}"],
      "key_files": ["{key_file}"],
      "related_paths": ["{related_path}"],
      "search_hints": ["{symbol_or_keyword}"],
      "dependencies": ["{dep_id}"],
      "dependents": ["{dep_id}"],
      "route_to": ["{dep_id}"],
      "route_from": ["{dep_id}"],
      "coverage": "{deep|light}",
      "confidence": "{high|medium|low}",
      "freshness": "{fresh|partial|stale}",
      "last_scanned": "{ISO-8601}"
    }
  },
  "indexes": {
    "by_path": {
      "{path_prefix}": ["{id}"]
    },
    "by_alias": {
      "{alias}": ["{id}"]
    },
    "by_export": {
      "{export_name}": ["{id}"]
    },
    "by_tag": {
      "{tag}": ["{id}"]
    },
    "by_file": {
      "{key_file}": ["{id}"]
    }
  }
}
