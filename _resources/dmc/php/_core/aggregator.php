<?php
	
// 	error_reporting(E_ALL);
// 	ini_set('display_errors', 1);
	
	header ('Content-Type:text/xml');

	if (isset($_GET['dir']) && $_GET['dir'] != ''){
		$aggregation_paths = ($_GET['dir'] != '' ? $_GET['dir'] : '/directory');
		$dsn = (isset($_GET['dsn']) && $_GET['dsn'] != '' ? $_GET['dsn'] : 'directory');
		echo get_xml($aggregation_paths, $dsn);
	}else{
		echo '<?xml version="1.0"?>';
		echo '<items />';
	}

	function get_xml($dir, $dsn) {
		// GENERATING ROOT XML NODE
		echo '<?xml version="1.0"?>';
		echo '<items>';
		foreach (get_xml_paths_from_aggregation_paths($dir) as $file){
			$xml = simplexml_load_file($file);
			if ($xml !== false && $xml->attributes()->dsn == $dsn){
				unset($xml->attributes()->dsn);
				echo preg_replace('(<\?xml.*\?>\n)', '', $xml->asXML());
			}
		}
		echo '</items>';
	}

	function get_xml_paths_from_aggregation_paths($aggregation_paths){
		$xml_paths = array();

		$aggregation_paths = explode(',', $aggregation_paths);

		foreach($aggregation_paths as $path){
			$path = trim($path); // trim whitespace
			$path = rtrim($path, '/'); // remove any trailing forward slashes
			$paths = get_xml_paths($_SERVER['DOCUMENT_ROOT'] . $path);
			$xml_paths = array_merge($xml_paths, $paths);
		}

		$xml_paths = array_unique($xml_paths); // remove duplicates
		return $xml_paths;
	}

	function get_xml_paths($path) {
		if(!file_exists($path)) return array(); // return empty array if path does not exists

		if(is_file($path)){ // if path is file only include it if it's an XML
			if(preg_match('/\.xml$/', $path)){
				return array($path);
			}else{
				return array();
			}
		}

		if($dh = opendir($path)) {
			$files = array();
			$inner_files = array();
			while($file = readdir($dh)) {
				if($file != '.' && $file != '..' && $file[0] != '.') {
					if(is_dir($path . '/' . $file)) {
						$inner_files = get_xml_paths($path . '/' . $file);
						if($inner_files != null) $files = array_merge($files, $inner_files); 
					} else {
						if(preg_match('/\.xml$/', $file)) array_push($files, $path . '/' . $file);
					}
				}
			}
			closedir($dh);
			return $files;
		}
	}

?>