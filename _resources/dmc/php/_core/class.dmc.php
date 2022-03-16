<?php

// 	header("Access-Control-Allow-Origin: *");

	class DMC {
		private $xml_docs = array();
		private $result_sets = array();
		private $data_folder = '/_resources/data/';
		
		public function __construct($data_folder = null){
			if($data_folder != null) $this->data_folder = $data_folder;
		}

		public function getResultSet($options){
			$options = $this->getOptions($options); // adds additional options from query string parameters and default options for options omitted.
			
			$xpath = $options['xpath'];
			
			$xml_path = $this->getXMLpath($options['datasource']);
			if($xpath=='') $xpath = 'item';
			$key = $xml_path.'-'.$xpath;
			
			//echo '<!-- key: '.$key.' -->';
			
			if(array_key_exists($key, $this->result_sets)){
				$result_set = $this->cloneResultSet($this->result_sets[$key]);
				unset($options['endpoint']); // endpoint moved to internal array so removing from options array.
				$result_set['meta']['options'] = $options;
				//echo '<!-- result_set pulled from cache: '.$key.' -->';
				return $result_set;
			}
			
			$result_set = array();
			$result_set['internal'] = array();
			$result_set['meta'] = array();
			
			if(array_key_exists($xml_path, $this->xml_docs)){
				$xml = $this->xml_docs[$xml_path];
				//echo '<!-- xml_docs pulled from cache: '.$xml_path.' -->';
			}else{
				$xml = simplexml_load_file(rtrim($_SERVER['DOCUMENT_ROOT'], '/') . $xml_path);
				$this->xml_docs[$xml_path] = $xml;
				//echo '<!-- xml_docs created cache: '.$xml_path.' -->';
				
				if($xml === false){
					if($options['endpoint'] == true) echo 'Failed to load XML document from "' . $xml_path . '" <br />Please verify the path is correct and try again.';
					return;
				}
				
			}
			
			$result_set['internal']['root_node'] = $xml->getName();
			$result_set['internal']['namespaces'] = $xml->getNamespaces(true);
			$result_set['internal']['endpoint'] = $options['endpoint']; // endpoint option moved to internal array.
			
			$result_set['items'] = $xml->xpath($xpath);
			$result_set['meta']['total'] = count($result_set['items']);
			
			$this->result_sets[$key] = $result_set;
			//echo '<!-- result_set created cache: '.$key.' -->';

			$result_set = $this->cloneResultSet($result_set);
			unset($options['endpoint']); // endpoint moved to internal array so removing from options array.
			$result_set['meta']['options'] = $options;
			return $result_set;
		}

		public function search($result_set, $search_phrase = '', $columns = '*', $case_sensitive = ''){
			
			if($result_set['meta']['options']['search_phrase'] != ''){
				$search_phrase = $result_set['meta']['options']['search_phrase'];
			}
			
			if($result_set['meta']['options']['search_columns'] != ''){
				$columns = $result_set['meta']['options']['search_columns'];
			}
			
			if($result_set['meta']['options']['search_case_sensitive'] != ''){
				$case_sensitive = $result_set['meta']['options']['search_case_sensitive'];
			}
			
			$search_phrase = trim($search_phrase);

			if($search_phrase == '') return $result_set;

			if($case_sensitive == 'true'){
				$search_subject = 'text()';
			}else{
				$search_subject = "translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')";
				$search_phrase = strtolower($search_phrase);
			}

			if($columns== '*'){
				if(strpos($search_phrase, "'") !== false){
					// use double quotes to wrap search phrase since there is a single quote present. Also remove any double quotes in the search phrase if they exist.
					$xpath = "node()[contains({$search_subject}, \"" . str_replace('"', '', $search_phrase) . "\")]";
				}else{
					$xpath = "node()[contains({$search_subject}, '{$search_phrase}')]";
				}
			}else{
				$columns_predicate = '1=0';
				foreach(explode(',', $columns) as $column){
					$column = trim($column);
					$columns_predicate .= " or name()='{$column}'";
				}

				if(strpos($search_phrase, "'") !== false){
					// use double quotes to wrap search phrase since there is a single quote present. Also remove any double quotes in the search phrase if they exist.
					$xpath = "node()[{$columns_predicate}][contains({$search_subject}, \"" . str_replace('"', '', $search_phrase) . "\")]";
				}else{
					$xpath = "node()[{$columns_predicate}][contains({$search_subject}, '{$search_phrase}')]";
				}
			}

			$result_set['meta']['options']['search_phrase'] = $search_phrase;
			$result_set['meta']['options']['search_columns'] = $columns;
			$result_set['meta']['options']['search_case_sensitive'] = $case_sensitive;

			$result_set = $this->xpathFilter($result_set, $xpath);

			return $result_set;
		}

		public function xpathFilter($result_set, $xpath){
			$result_items = array();

			foreach($result_set['items'] as $i){
				if(count($i->xpath($xpath))){
					$result_items[] = $i;
				}
			}
			$result_set['items'] = $result_items;
			$result_set['meta']['total'] = count($result_set['items']);

			return $result_set;
		}

		public function render($result_set, $templating_function){
			if($templating_function[1]=='') $templating_function = array($this, 'htmlTable');
			$return_type = isset($_GET['returntype']) ? $_GET['returntype'] : "html";
			if(!$result_set['internal']['endpoint']) $return_type = 'html';
			
			switch(strtolower($return_type)){
				case 'html':
				return call_user_func($templating_function, $result_set);
				break;
				case 'json':
				return $this->renderJSON($result_set);
				break;
				case 'xml':
				return $this->renderXML($result_set);
				break;
			}
		}
		
		// public helper functions
		public function updateQuerystringParameter($qs, $name, $value){
			parse_str($qs, $qsa);

			$qsa[$name] = (string)$value;

			return http_build_query($qsa);
		}

		public function removeQuerystringParameter($qs, $name){
			parse_str($qs, $qsa);

			unset($qsa[$name]);

			return http_build_query($qsa);
		}
		
		public function getQuerystringParameter($parameter){
			if(isset($_GET[$parameter])) return $_GET[$parameter];
			return "";
		}
		
		private function getOptions($options = array()){
			
			$default_options = array(
				'endpoint'=> false,
				'querystring_control'=> 'false',
				'datasource'=> '',
				'xpath'=> '',
				'type'=> '',
				'page'=> '',
				'items_per_page'=> '',
				'max'=> '',
				'sort'=> '',
				'search_phrase'=> '',
				'search_columns'=> '',
				'search_case_sensitive'=> '',
				'select'=> '',
				'returntype'=>'html',
				'max_page_links'=>'',
				'distinct'=>'false',
				'json_always_array'=>''
			);
			
			if(isset($options['endpoint']) && $options['endpoint'] == true){
				// when endpoint is used allow all querystring variables to override options.
				$options['querystring_control'] = 'true';
				$options = $_GET + $options;
			}else if(isset($options['querystring_control']) && strtolower($options['querystring_control']) == 'true'){
				// when endpoint not used and querystring control is turned on allow only certain querystring variables to override options.
				$options['querystring_control'] = 'true';
				$overwritableOptions = array('page',
											 'items_per_page',
											 'max',
											 'sort',
											 'search_phrase',
											 'search_columns',
											 'search_case_sensitive',
											 'max_page_links');

				foreach($overwritableOptions as $option){
					if(isset($_GET[$option])) $options[$option] = $_GET[$option];
				}
			}
			
			return $options + $default_options;
		}
		
		private function htmlTable($result_set){

			if(count($result_set['items']) == 0) return;

			// $this->truncate($result_set, 1000); // limit to sample set of no more then 1k items.

			$result = '';

			$result .= '<table>';
			$result .= '<thead>';
			$result .= '<tr>';

			$columns = array();

			foreach ($result_set['items'][0]->children() as $child){
				if(!in_array($child->getName(), $columns)) $columns[] = $child->getName();
			}

			foreach ($columns as $column){
				$result .= "<th>{$column}</th>";
			}

			$result .= '</tr>';
			$result .= '</thead>';
			$result .= '<tbody>';

			foreach ($result_set['items'] as $i){
				$result .= '<tr>';
				foreach ($columns as $column){
					if($i->{$column}->count() > 1){
						$columnValue = '<ol>';
						foreach ($i->{$column} as $child){
							$columnValue .= '<li>' . $child . '</li>';
						}
						$columnValue .= '</ol>';
					}else{
						$columnValue = $i->{$column};
					}
					$result .= '<td>' . $columnValue . '</td>';
				}
				$result .= '</tr>';
			}

			$result .= '</tbody>';
			$result .= '</table>';			

			return $result;
		}

		public function truncate($result_set, $max = ''){
			
			if($result_set['meta']['options']['max'] != ''){
				$max = $result_set['meta']['options']['max'];
			}
			
			$max = trim($max);
			if($this->isPositiveInteger($max)){
				$result_set['items'] = array_splice($result_set['items'], 0, $max);
				$result_set['meta']['options']['max'] = $max;
			}
    		return $result_set;
		}
		
		public function select($result_set, $select_columns = ''){
			
			if($result_set['meta']['options']['select'] != ''){
				$select_columns = $result_set['meta']['options']['select'];
			}
			
			if($select_columns == '*' || $select_columns == '') return $result_set;

			$result_set['meta']['options']['select'] = $select_columns;

			$select_columns = explode(',', preg_replace('/\s*,\s*/', ',', $select_columns));

			foreach($result_set['items'] as $i){
				$nodes_to_remove = array();

				foreach($i->children() as $child){
					if(!in_array($child->getName(), $select_columns)) $nodes_to_remove[] = $child;
				}
				foreach ($nodes_to_remove as $node) {
					unset($node[0]);
				}
			}

			return $result_set;
		}

		public function distinct($result_set){
			if($result_set['meta']['options']['distinct'] != 'true') return $result_set;
			
			$result_items = array();
			$hash_set = array();

			foreach($result_set['items'] as $i){
				$strValue = $i->asXML();
				
				if(!isset($hash_set[$strValue])){
					$result_items[] = $i;
					$hash_set[$strValue] = true;
				}
			}
			
			$result_set['items'] = $result_items;
			$result_set['meta']['total'] = count($result_set['items']);

			return $result_set;
		}

		public function sort($result_set, $sort_statement = ''){
			
			if($result_set['meta']['options']['sort'] != ''){
				$sort_statement = $result_set['meta']['options']['sort'];
			}
			
			$sort_statement = trim($sort_statement);
			
			if($sort_statement == '') return $result_set;
			
			$items = $result_set['items'];

			$parsed_sort_statement = $this->parseSortStatement($sort_statement);
			
			foreach ($parsed_sort_statement as $i) {
				$field = $i['field'];
				$direction = $i['direction'];
				$type = $i['type'];

				switch($type){
					case 'date':
					case 'rand':
					case 'number':
						$sort_type = SORT_NUMERIC;
					break;
					default:
						$sort_type = SORT_STRING;
				}

				if (is_string($field)) {
					$tmp = array();
					foreach ($items as $key => $row){
						if($type == 'rand'){
							$field_value = rand();
						}else if($field == '.'){
							$field_value = strtolower($row);
						}else{
							$field_value = strtolower($row->{$field});
						}

						if($type == 'date'){
							$field_value = strtotime($field_value);
						}

						$tmp[$key] = $field_value;
					}
					$args[] = $tmp;
					$args[] = $direction;
					$args[] = $sort_type;
				}
			}
			
			$args = array_merge($args, array(&$items));
			
			
			// this switch block can be replaced with 'call_user_func_array('array_multisort', $args);' for PHP >= 5.4.0
// 			switch(count($args)){
// 				case 4: // sorting by one column
// 					array_multisort($args[0], $args[1], $args[2], $args[3]);
// 					break;
// 				case 7: // sorting by two columns
// 					array_multisort($args[0], $args[1], $args[2], $args[3], $args[4], $args[5], $args[6]);
// 					break;
// 				case 10: // sorting by three column
// 					array_multisort($args[0], $args[1], $args[2], $args[3], $args[4], $args[5], $args[6], $args[7], $args[8], $args[9]);
// 					break;
// 				default: // sorting by any number of columns as long as PHP version is 5.4 or newer.
// 					call_user_func_array('array_multisort', $args);
// 			}
			
			call_user_func_array('array_multisort', $args); // this only works in PHP version 5.4 or newer.
			
			$result_set['items'] = array_pop($args);

			$result_set['meta']['options']['sort'] = $sort_statement;

			return $result_set;
		}

		public function paginate($result_set, $items_per_page = '', $current_page = ''){
			
			if($result_set['meta']['options']['items_per_page'] != ''){
				$items_per_page = $result_set['meta']['options']['items_per_page'];
			}
			
			if($result_set['meta']['options']['page'] != ''){
				$current_page = $result_set['meta']['options']['page'];
			}

			if(!$this->isPositiveInteger($items_per_page)) return $result_set; // Not a valid positive integer so don't paginate, just return result_set.
			
			if(!$this->isPositiveInteger($current_page)) $current_page = 1; // Not a valid positive integer so default to 1.
			
			$items = $result_set['items'];

			$total_count = count($items);
			
			$rangeStartIndex = ($current_page - 1) * $items_per_page;
			$rangeLength = $items_per_page;

			if($rangeStartIndex + $items_per_page > $total_count){
				$rangeLength = $total_count - $rangeStartIndex;
			}

			$result_set['items'] = array_slice($items, $rangeStartIndex, $rangeLength);
			
			$result_set['meta']['pagination'] = array();
			$result_set['meta']['pagination']['page_count'] = ceil($total_count / $items_per_page);
			$result_set['meta']['pagination']['current_page'] = $current_page;
			$result_set['meta']['pagination']['items_per_page'] = $items_per_page;
			$result_set['meta']['pagination']['rangeStartIndex'] = $rangeStartIndex;
			
			$result_set['meta']['pagination']['first_linked_page'] = $this->getFirstLinkedPage($result_set);
			$result_set['meta']['pagination']['last_linked_page'] = $this->getLastLinkedPage($result_set);
			
			return $result_set;
		}

		private function isPositiveInteger($s){
			return preg_match('/^[1-9]+\d*$/', $s);
		}

		private function parseSortStatement($sort_statement){
			$result = array();

			foreach (explode(',', $sort_statement) as $n => $field) {
				$tmp = array();
				
				$field = trim($field);
				$type = 'string';
				if(preg_match("/^([^(]+)\(/", $field, $matches)){
					$type = trim($matches[1]);
					$field = preg_replace("/^[^(]+\(/", "", $field);
					$field = preg_replace("/[()]/", "", $field);
					$field = trim($field);
				}else if($this->startsWith($field, 'rand()')){
					$type = 'rand';
					$field = '';
				}

				$direction = (preg_match("/\sdesc$/i", $field))?SORT_DESC:SORT_ASC;
				$field = preg_replace("/[\s].*$/", "", $field);

				$tmp['field'] = $field;
				$tmp['direction'] = $direction;
				$tmp['type'] = $type;

				$result[] = $tmp;
			}

			return $result;
		}
		
		private function renderJSON($result_set){
			//var_dump($result_set);
			
			header('Content-Type: application/json');
			$result_set['items'] = $this->getItemsWithNamespaceNodes($result_set);
			
			
			
			if($this->shouldIncludeMetaData()){
				if($result_set['internal']['endpoint'] == true) unset($result_set['meta']['options']['querystring_control']);
				
				$json_output = '{"meta":';

				$json_output .= json_encode($result_set['meta']);
				
				$json_output .= ',"items":';
				
				$json_output .= $this->getItemsJSONOptimized($result_set);
				
				$json_output .= '}';
				
				return $json_output;
			}else{
				
				return $this->getItemsJSONOptimized($result_set);
			}
			
		}
		
		private function getItemsJSONOptimized($result_set){
			$i = 0;
			$len = count($result_set['items']);
			$json_output = '[';
			foreach($result_set['items'] as $item){
				$item_json = json_encode($item);
				$item_json = preg_replace('/^{\s*"[^"]+"\s*:\s*/', '', $item_json);
				$item_json = preg_replace('/}\s*$/', '', $item_json);

				$json_output .= $item_json;

				if(++$i < $len) $json_output .= ',';
			}
			$json_output .= ']';
			return $json_output;
		}
		
		private function getItemsWithNamespaceNodes($result_set){
			$items = $result_set['items'];
			
			$xml_to_array_options = array();
			
			$always_array = $result_set['meta']['options']['json_always_array'];
			$always_array = trim($always_array);
			$always_array = preg_replace('/[\s]*,[\s]*/', ',', $always_array);
			
			if($always_array != '') $xml_to_array_options["alwaysArray"] = explode(',', $always_array);

			$itemsWithNamespaceNodes = array();
			foreach($items as $i){
				array_push($itemsWithNamespaceNodes, $this->xmlToArray($i, $xml_to_array_options));
			}
			return $itemsWithNamespaceNodes;
		}
		
		private function renderXML($result_set){
			$output = '';
			$include_meta_data = $this->shouldIncludeMetaData();
			$internal = $result_set['internal'];
			$meta = $result_set['meta'];

			if(count($result_set['items']) == 1 && $result_set['items'][0]->getName() == $internal['root_node']){
				$wrap_root_node = false;
			}else{
				$wrap_root_node = true;
			}
			
			header('Content-Type: text/xml');
			$output .= '<?xml version="1.0" encoding="UTF-8"?>';
			if($include_meta_data){
				$output .= '<package';
				foreach($internal['namespaces'] as $name => $value) {
					$output .= ' xmlns:' . $name.'="' . $value . '"';
				}
				$output .= '>';
				if($wrap_root_node) $output .= '<' . $internal['root_node'] . '>';
			}else{
				if($wrap_root_node){
					$output .= '<' . $internal['root_node'];
					foreach($internal['namespaces'] as $name => $value) {
						$output .= ' xmlns:' . $name.'="' . $value . '"';
					}
					$output .= '>';
				}
			}

			if(count($result_set['items']) == 1){
				// when the single item is the root the delaration line should be removed.
				$output .= preg_replace('/^<\?xml.*\?>[\n]*/', '', strtr($result_set['items'][0]->asXML(), array("\n" => '')));
			}else{
				foreach($result_set['items'] as $i){
					$xml = $i->asXML();
					$xml = preg_replace('/(\>)\s*(\<)/m', '$1$2', $xml);
					$output .= $xml;
				}
			}

			if($wrap_root_node) $output .= '</' . $internal['root_node'] . '>';

			if($include_meta_data){
				if($result_set['internal']['endpoint'] == true) unset($meta['options']['querystring_control']);
				unset($result_set['internal']); // Remove internal. Shouldn't be included in output.
				$output .= $this->arrayToXML($meta, 'meta');
				$output .= '</package>';
			}
			
			return $output;
			
		}

		private function getXMLpath($datasource){
			$result = $datasource;
			
			if(!$this->startsWith($datasource, '/')){
				$data_folder = rtrim($this->data_folder, '/'); // remove trailing slashes
				if($data_folder != "/") $data_folder .= '/'; // add trailing slash

				$result = $data_folder . $datasource;
			}
			
			if(!$this->endsWith($result, '.xml')) $result .= '.xml';
			
			return $result;
		}
			   
		private function shouldIncludeMetaData(){
			$metadata = isset($_GET['metadata']) ? $_GET['metadata'] : "false";
			if($metadata == 'true') return true;
			return false;
		}
		
		private function startsWith($haystack, $needle){
			$length = strlen($needle);
			return (substr($haystack, 0, $length) === $needle);
		}

		private function endsWith($haystack, $needle){
			$length = strlen($needle);
			if ($length == 0) {
				return true;
			}

			return (substr($haystack, -$length) === $needle);
		}
		
		private function getFirstLinkedPage($result_set){
			$current_page = $result_set['meta']['pagination']['current_page'];
			$max_page_links = $result_set['meta']['options']['max_page_links'];
			$page_count = $result_set['meta']['pagination']['page_count'];
			
			if(!$this->isPositiveInteger($max_page_links)) return 1;
			
			$travel = floor($max_page_links / 2);
			$first_linked_page = $current_page - $travel;
			
			if($max_page_links % 2 == 0) $first_linked_page = $first_linked_page + 1;
			
			if($first_linked_page > $page_count - $max_page_links + 1) $first_linked_page = $page_count - $max_page_links + 1;
			if($first_linked_page < 1) return 1;
			
			return $first_linked_page;
		}
		
		private function getLastLinkedPage($result_set){
			$current_page = $result_set['meta']['pagination']['current_page'];
			$max_page_links = $result_set['meta']['options']['max_page_links'];
			$page_count = $result_set['meta']['pagination']['page_count'];
			
			if(!$this->isPositiveInteger($max_page_links)) return $page_count;
			
			$travel = floor($max_page_links / 2);
			$last_linked_page = $current_page + $travel;
			
			if($last_linked_page < $max_page_links) $last_linked_page = $max_page_links;
			
			if($last_linked_page > $page_count) $last_linked_page = $page_count;
			
			return $last_linked_page;
		}

		private function cloneResultSet($resultSet){
			return array_merge(array(), $resultSet);
		}
		
		private function arrayToXML($array, $root_name, &$xml = null) {
			if($xml == null){
				$xml = new SimpleXMLElement("<" . $root_name . " />");
			}


			foreach($array as $key => $value) {
				if(is_array($value)) {
					if(!is_numeric($key)){
						$subnode = $xml->addChild("$key");
						$this->arrayToXML($value, $root_name, $subnode);
					} else {
						$this->arrayToXML($value, $root_name, $xml);
					}
				} else {
					$xml->addChild("$key","$value");
				}
			}
			return preg_replace('/^<\?xml.*\?>[\n]*/', '', $xml->asXML());
		}
		
		// The following function was pulled from: https://outlandish.com/blog/tutorial/xml-to-json/
		private function xmlToArray($xml, $options = array()) {
			$defaults = array(
				'namespaceSeparator' => '-',//you may want this to be something other than a colon
				'attributePrefix' => '@',   //to distinguish between attributes and nodes with the same name
				'alwaysArray' => array(),   //array of xml tag names which should always become arrays
				'autoArray' => true,        //only create arrays for tags which appear more than once
				'textContent' => '$',       //key used for the text content of elements
				'autoText' => true,         //skip textContent key if node has no attributes or child nodes
				'keySearch' => false,       //optional search and replace on tag and attribute names
				'keyReplace' => false       //replace values for above search values (as passed to str_replace())
			);
			$options = array_merge($defaults, $options);
			$namespaces = $xml->getDocNamespaces();
			$namespaces[''] = null; //add base (empty) namespace

			//get attributes from all namespaces
			$attributesArray = array();
			foreach ($namespaces as $prefix => $namespace) {
				foreach ($xml->attributes($namespace) as $attributeName => $attribute) {
					//replace characters in attribute name
					if ($options['keySearch']) $attributeName =
						str_replace($options['keySearch'], $options['keyReplace'], $attributeName);
					$attributeKey = $options['attributePrefix']
						. ($prefix ? $prefix . $options['namespaceSeparator'] : '')
						. $attributeName;
					$attributesArray[$attributeKey] = (string)$attribute;
				}
			}

			//get child nodes from all namespaces
			$tagsArray = array();
			foreach ($namespaces as $prefix => $namespace) {
				foreach ($xml->children($namespace) as $childXml) {
					//recurse into child nodes
					$childArray = $this->xmlToArray($childXml, $options);
					
					// list($childTagName, $childProperties) = each($childArray); // the each function was deprecated in php 7.2
					
					$childTagName = key($childArray);
					$childProperties = current($childArray);

					//replace characters in tag name
					if ($options['keySearch']) $childTagName =
						str_replace($options['keySearch'], $options['keyReplace'], $childTagName);
					//add namespace prefix, if any
					if ($prefix) $childTagName = $prefix . $options['namespaceSeparator'] . $childTagName;

					if (!isset($tagsArray[$childTagName])) {
						//only entry with this key
						//test if tags of this type should always be arrays, no matter the element count
						$tagsArray[$childTagName] =
							in_array($childTagName, $options['alwaysArray']) || !$options['autoArray']
							? array($childProperties) : $childProperties;
					} elseif (
						is_array($tagsArray[$childTagName]) && array_keys($tagsArray[$childTagName])
						=== range(0, count($tagsArray[$childTagName]) - 1)
					) {
						//key already exists and is integer indexed array
						$tagsArray[$childTagName][] = $childProperties;
					} else {
						//key exists so convert to integer indexed array with previous value in position 0
						$tagsArray[$childTagName] = array($tagsArray[$childTagName], $childProperties);
					}
				}
			}

			//get text content of node
			$textContentArray = array();
			$plainText = trim((string)$xml);
			if ($plainText !== '') $textContentArray[$options['textContent']] = $plainText;

			//stick it all together
			$propertiesArray = !$options['autoText'] || $attributesArray || $tagsArray || ($plainText === '')
				? array_merge($attributesArray, $tagsArray, $textContentArray) : $plainText;

			//return node as array
			return array(
				$xml->getName() => $propertiesArray
			);
		}

	}

?>