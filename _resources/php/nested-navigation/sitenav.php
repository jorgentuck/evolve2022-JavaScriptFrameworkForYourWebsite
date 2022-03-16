<?php
// Show all errors
//error_reporting(E_ALL);

$nav_filename = "/_nav.ounav";
// regex value of the index page, please escape period
$index_filename = "index\.html";

if(!isset($nav)){ $nav = (isset($_GET["nav"]) && strlen($_GET["nav"]) > 0) ? htmlspecialchars($_GET["nav"]) : $nav_filename; }

$server_file_path = $_SERVER["DOCUMENT_ROOT"] . $nav;
// $current_directory = str_replace($nav_filename, "", $nav);
$current_directory = str_replace($nav_filename, "", $nav) . "/";  // Added closing slash, since the replace strips it
// $processed_section = array();
$processed_section = array($current_directory);  // Added starting directory

$nest_level = 0;
$nest_limit = -1;

$html = "<ul id='side-nav-accordion' class='nav'>";
process_nav_file($server_file_path);
$html .= "</ul>";

echo $html;

// process the navigation files
function process_nav_file($file_path){
	global $nest_level;
	$nest_level++;

	if(file_exists($file_path)){
		$file = file_get_contents($file_path);
		//remove html comments
		$file = preg_replace("<!\-\-.*?\-\->" , "", $file);
		$regex = '/(<li([^>]*?)>[\s]*?<a([^>]*?)href="([^"]+?)"([^>]*?)>([\s\S]*?)<\/a>[\s]*?<\/li>)/';

		if(preg_match($regex, $file)) { preg_replace_callback($regex,"match_li",$file); }	
	}

	$nest_level--;
}

// function that matches the regular li
function match_li($matches){
	global $html;
	global $index_filename;

	$li = $matches[0];
	// replacing the class since this script should output the class, not OU Campus
	$li_attributes = remove_class_attribute($matches[2]);
	// replacing the class since this script should output the class, not OU Campuss
	$a_attributes_before = remove_class_attribute($matches[3]);
	$full_href = $matches[4];
	// replacing the class since this script should output the class, not OU Campus
	$a_attributes_after = remove_class_attribute($matches[5]);

	$title = $matches[6];
	$regex = '/<li([^>]*?)>[\s]*?<a([^>]*?)href=\"(\/[^"]*?\/)(' . $index_filename . ')?\"([^>]*?)>([\s\S]*?)<\/a>[\s]*?<\/li>/';

	if (preg_match($regex, $li)) { preg_replace_callback($regex,"match_section_li",$li); }

	else { 
		$html .= "<li{$li_attributes} class='nav-item'><a{$a_attributes_before} class=\" nav-link\" href=\"{$full_href}\"{$a_attributes_after}>{$title}</a></li>";
	}	
}

// function to remove the class attributes
function remove_class_attribute($final_string) {
	if (strpos($final_string, 'class="') !== false) {
		$final_string = preg_replace('/class="[^"]*?"/', "", $final_string);
	}
	return $final_string;
}

// function that matches the section li
function match_section_li($matches){
	global $html;
	global $current_directory;
	global $nest_level;
	global $nest_limit;
	global $processed_section;
	global $nav_filename;

	$li = $matches[0];
	// replacing the class since this script should output the class, not OU Campus
	$li_attributes = remove_class_attribute($matches[1]);
	// replacing the class since this script should output the class, not OU Campus
	$a_attributes_before = remove_class_attribute($matches[2]);
	$href = $matches[3];
	$page = $matches[4];
	// replacing the class since this script should output the class, not OU Campus
	$a_attributes_after = remove_class_attribute($matches[5]);
	$title = $matches[6];

	$file_path = realpath($_SERVER["DOCUMENT_ROOT"].$href.$nav_filename);

	$process_nav = true;

	//check if file exists
	if (file_exists($file_path)) {
		$file = file_get_contents($file_path);
		//remove html comments
		$file = preg_replace("<!\-\-.*?\-\->" , "", $file);

		//make sure the file contains at least one <li>, so an empty <ul> is not generated
		$regex = '/(<li[^>]*?>[\s]*?<a[^>]*?>[\s\S]*?<\/a>[\s]*?<\/li>)/';

		if(!preg_match($regex, $file))
			$process_nav = false;
	}
	//no _nav in section
	else { $process_nav = false; }

	//check if this is the current sections index page link
	if(!strcmp($href, $current_directory)) { $process_nav = false; }
	//check if class=ou-no-subnav within the li's node
	if (strpos($li, "class=\"ou-no-subnav\"") !== false){ $process_nav = false; }	
	// nest limit reached
	if ($nest_level == $nest_limit){ $process_nav = false; }	
	//check if we've already processed this section before (cross-link)
	if (in_array($href, $processed_section)){ $process_nav = false; }

	if ($process_nav) {
		//add each processed section to array
		if($href != '') { $processed_section[] = $href; }

		// this is where the nesting occurs
		$li_id = uniqid();
		$html .= "<li{$li_attributes} class='nav-item'><a{$a_attributes_before} class='nav-link' data-toggle='collapse' data-parent='#side-nav-accordion' href=\"#side-nav-$li_id\"{$a_attributes_after}>{$title}</a><div id='side-nav-$li_id' class=\"collapse\"> <ul class=\"nav level-{$nest_level}\">";

		$current_directory = $href;

		process_nav_file($file_path);

		$html .= "</ul></div></li>";
	}
	else {
		$html .= "<li{$li_attributes} class='nav-item'><a{$a_attributes_before} class='nav-link' href=\"{$href}{$page}\"{$a_attributes_after}>{$title}</a></li>";
	}	
}
?>