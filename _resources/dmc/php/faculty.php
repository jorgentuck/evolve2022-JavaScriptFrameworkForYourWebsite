<?php

date_default_timezone_set('America/Los_Angeles');

// 	error_reporting( E_ALL );
// 	ini_set('display_errors', 1);

require_once('_core/class.dmc.php');

$facultyDMC = new FacultyDMC(); // optionally pass an alternate root relative path to data folder. Default is "/_resources/data/".

if(str_replace('\\', '/', strtolower(__FILE__)) == str_replace('\\', '/', strtolower($_SERVER['SCRIPT_FILENAME'])) && isset($_GET['datasource']) && $_GET['datasource'] != ''){
	get_faculty_dmc_output(array('endpoint' => true));
}

function get_faculty_dmc_output($options){
	global $facultyDMC;
	return $facultyDMC->get_output($options);
}

class FacultyDMC {

	private $dmc;

	public function __construct($data_folder = null){
		$this->dmc = new DMC($data_folder);
	}

	public function get_output($options){
		$resultSet = $this->dmc->getResultSet($options);
		$templating_function = '';

		switch($resultSet['meta']['options']['type']){
			case 'details':
			$templating_function = 'render_details';
			break;
			case 'listing':
			$templating_function = 'render_listing';
			break;
			case 'faculty_snap_shot':
			$templating_function = 'render_faculty_snap_shot';
			break;
		}


		//$resultSet = $this->dmc->xpathFilter($resultSet, "node()[name()='FIRST_NAME' or name()='LAST_NAME'][starts-with(text(), 'P')]");
		$resultSet = $this->dmc->search($resultSet);
		$resultSet = $this->dmc->distinct($resultSet);
		$resultSet = $this->dmc->sort($resultSet);
		$resultSet = $this->dmc->truncate($resultSet);
		$resultSet = $this->dmc->paginate($resultSet);
		$resultSet = $this->dmc->select($resultSet);

		//echo 'Current PHP version: ' . phpversion();
		echo $this->dmc->render($resultSet, array($this, $templating_function));
	}

	public function render_details($resultSet){
		$output = "";
		$items = $resultSet['items'];

		foreach($items as $i){
			$office = "{$i->building} {$i->room_number}";
			$phone = $this->format_phone($i->phone);
			$output .= "<h2>{$i->first_name} {$i->LAST_NAME}</h2>";
			if($i->title != '' || $i->department != ''){
				$output .= '<p>';
				$output .= '	<strong>';

				if($i->title != '') $output .= $i->title;
				if($i->title != '' && $i->department != '') $output .= ', ';
				if($i->department != '') $output .= $i->department;

				$output .= '	</strong>';
				$output .= '</p>';
			}

			if($office != '') $output .= "<p>Office: {$office}</p>";
			if($phone != '') $output .= "<p>Phone: <a itemprop='telephone' href='tel:{$phone}'>{$phone}</a></p>";
			if($i->email != '') $output .= "<p>E-mail: <a itemprop='email' href='mailto:{$i->email}'>{$i->email}</a></p>";
		}

		return $output;
	}



	public function render_listing($resultSet){
		$output = "";
		$filterForm = $this->render_filter_form($resultSet);
		$pagination = $this->render_pagination($resultSet);

		$items = $resultSet['items'];
		foreach($items as $i){
			$office = $i->building . ' ' . $i->room_number;
			$phoneHref = preg_replace('/[^0-9]/', '', $i->phone);;
			$href = $i->attributes()->href;

			$output .= '<tr>';
			$output .= '<td headers="fname"><strong><a href="'.$href.'">'.$i->first_name.'</a></strong></td>';
			$output .= '<td headers="lname"><strong><a href="'.$href.'">'.$i->last_name.'</a></strong></td>';
			$output .= '<td headers="title">'.$i->title.'</td>';
			$output .= '<td headers="department">'.$i->department.'</td>';
			$output .= '<td headers="location">'.$office.'</td>';
			$output .= '<td headers="phone">';
			if ($phoneHref != '') {
				$output .= '<a href="tel:'.$phoneHref.'">'.$i->phone.'</a>';	
			}
			$output .= '</td>';
			$output .= '<td headers="email">';
			if ($i->email != '') {
				$output .= '<a href="mailto:'.$i->email.'">'.$i->email.'</a>';	
			}
			$output .= '</td>';
			$output .= '</tr>';
		}

		return $output;
	}




	public function render_faculty_snap_shot($resultSet){
		$output = "";
		$items = $resultSet['items'];
		$title = $resultSet['meta']['options']['title'];
		$output .=  '	<div class="container">';
		$output .= '   <p style="font-size:28px;">'. $title . '</p>';
		$output .=  '	<div class="ou-row">';
		foreach ($items as $i) {
			$href = $i->attributes()->href;
			$image = $i->image->img->attributes();
			$output .=  '	<div class="col-sm-4">';
			$output .=  '	<div class="card" style="width: 18rem;">';
			if($image->src != ''){
				$output .=  '		<img src="'.$image->src .'" class="card-img-top" alt="'.$image->alt .'">';
			}else{
				$output .=  '		<img src=" /_resources/images/placeholder.png" class="card-img-top" alt="placeholder-image">';
			}
			$output .=  '		<div class="card-body">';
			$output .=  '		<p style="font-size:20px;" class="card-title">'. $i->first_name .' '. $i->last_name .'</p>';
			$output .=  '		<p class="card-text">'. $i->department .'</p>';
			$output .=  '	<a href="'.$href.'" class="btn btn-primary">Visit Profile</a>';
			$output .=  '  </div>';
			$output .=  '</div>';
			$output .=  '</div>';
		}
		$output .=  '</div>';
		$output .=  '</div>';

		return $output;
	}



	private function render_filter_form($resultSet){
		$items_per_page_options = array(
			"5"=>"5",
			"10"=>"10",
			"20"=>"20",
			"30"=>"30",
			"40"=>"40",
			"50"=>"50",
			"100"=>"100",
			"200"=>"200",
			""=>"All"
		);


		$result = '';
		$result .= '<form>';
		$result .= '<div class="large-12 columns">';
		$result .= '	<div class="row collapse">';
		$result .= '		<div class="small-4 columns">';
		$result .= '			<label>Items per Page';
		$result .= '				<select name="items_per_page">';
		foreach ($items_per_page_options as $key => $val){ 
			$result .= '<option value="'.$key.'"';
			if($key == $resultSet['meta']['options']['items_per_page']) $result .= ' selected';
			$result .= '>'.$val.'</option>';

		}
		$result .= '				</select>';
		$result .= '			</label>';
		$result .= '		</div>';
		$result .= '		<div class="small-6 columns">';
		$result .= '			<label>Search Phrase';
		$result .= '				<input type="text" name="search_phrase" value="'.$resultSet['meta']['options']['search_phrase'].'">';
		$result .= '			</label>';
		$result .= '		</div>';
		$result .= '		<div class="small-2 columns">';
		$result .= '			<label>&nbsp;';
		$result .= '				<input type="submit" class="button postfix" value="search" />';
		$result .= '			</label>';
		$result .= '		</div>';
		$result .= '	</div>';
		$result .= '</div>';
		$result .= $this->build_hidden_inputs($resultSet);
		$result .= '</form>';
		return $result . '<br style="clear:right;" />';

	}

	private function build_hidden_inputs($resultSet){
		$result = '';

		$result .= '<input type="hidden" name="sort" value="'.$resultSet['meta']['options']['sort'].'" />';
		$result .= '<input type="hidden" name="page" value="1" />';

		return $result;
	}

	private function render_pagination($resultSet){
		$result = '';

		if(!isset($resultSet['meta']['pagination'])) return $result;

		$totalPages = $resultSet['meta']['pagination']['page_count'];
		$page = $resultSet['meta']['pagination']['current_page'];
		if($totalPages < 2) return ''; // only return the pagination if there are more than 1 page.
		$previousPage = $page - 1;
		$nextPage = $page + 1;

		$query_string = $_SERVER['QUERY_STRING'];
		$result .= '<nav aria-label="Page navigation"><ul class="pagination pull-right">';
		if($previousPage > 0){
			$result .= '    <li class="page-item"><a class="page-link" href="?' . $this->dmc->updateQuerystringParameter($query_string, 'page', $previousPage) . '">« <span class="sr-only">Previous</span></a></li>';
		}
		for ($i = 1; $i <= $totalPages; $i++) {
			if($i == $page){
				$result .= '    <li class="page-item active"><a class="page-link" href="?' . $this->dmc->updateQuerystringParameter($query_string, 'page', $i) . '">' . $i . '</a></li>';
			}else{
				$result .= '    <li class="page-item"><a class="page-link" href="?' . $this->dmc->updateQuerystringParameter($query_string, 'page', $i) . '">' . $i . '</a></li>';
			}
		}
		if($nextPage <= $totalPages){
			$result .= '    <li class="page-item"><a class="page-link" href="?' . $this->dmc->updateQuerystringParameter($query_string, 'page', $nextPage) . '"><span class="sr-only">Next</span> »</a></li>';    
		}
		$result .= '</ul></nav>';
		return $result . '<br style="clear:right;" />';
	}

	private function format_phone($phone){
		$phone = preg_replace('/[\D]/', '', $phone); // remove non-digit characters

		if(strlen($phone) == 10){
			$phone = preg_replace('/^(.{3})(.{3})(.{4})$/', '($1) $2-$3', $phone);

			return $phone;
		}

		return '';
	}
}
?>