<?php
			$config = array(
				"ssm_host" => "http://127.0.0.1", //SSM Host location. Change this if the SSM is on a different server than the connector script.
				"ssm_port" => "7518",
				"ssm_path" => "",
				"captcha_secret" => "" // Set to Google reCAPTCHA secret. CAPTCHA validation is bypassed if this is left empty.
			);
			// ADD Site Names and UUIDs
			$site_uuids = array(
				
					"sample-bpt" => "f4cd1211-de1e-4138-8d75-8c0f60701253"
			);
			$debug = false; // enable "debug mode" for this script

class ouldp {
	public $config;

	public function __construct($config) {
		$this->config = $config;
	}

	public function send($method, $param) {
		global $debug;
		$curlError = "";
		$result = array("active" => false, "message" => "", "data" => "");
		$gen_usr_err_ms = "The given file(s) do not match the criteria. Please try again.";
		foreach ($_FILES as $key => $file) {
			// no file was uploaded, completely ignore it
			if ($file["error"] != UPLOAD_ERR_NO_FILE) {
				// checking to see if the given files is not ok, if not ok return and stop processing
				if ($file["error"] != UPLOAD_ERR_OK) { return array("active" => false, "message" => ("Faultcode: 100" . $file["error"]), "data" => $gen_usr_err_ms); }
				// so there is actually a file uploaded with no errors, lets process it.
				// have to split and end the filename in two seperate operations to avoid php notice: Only variables should be passed by reference in
				$temp_filename = explode("/", $file["name"]);
				$temp_actual_filename = end($temp_filename);
				// conditional checkes on the filename and filesize lengths
				$length_passes = ((1 <= strlen($temp_actual_filename)) && (strlen($temp_actual_filename) <= 256));
				$filesize_pass = ((1 <= $file["size"]) && ($file["size"] <= 26214400));
				// make sure the name is set and length less than 256 characters, 
				// the bytes are greater than 0 and less than 25mb and file didn't error
				if ($length_passes && $filesize_pass) {
					$cur_file = @fopen($file["tmp_name"], "rb");
					if ($cur_file) {
						$param[2][$key] = array(
							'name' => $file["name"],
							'type' => $file["type"],
							'size' => $file["size"],
							'data' => base64_encode(fread($cur_file, $file["size"]))
						);
						fclose($cur_file);
					}
					else { return array("active" => false, "message" => "Faultcode: 1010", "data" => $gen_usr_err_ms); }
				}
				else { return array("active" => false, "message" => "Faultcode: 1011", "data" => $gen_usr_err_ms); }
			}
		}

		// turns form data into xmlrpc
		$output_options = ['encoding' => 'utf-8', 'escaping' => 'markup', 'verbosity' => 'no_white_space'];
		$request = @xmlrpc_encode_request($method, $param, $output_options);
		if ($request) {
			// Handle encoding
			$request = preg_replace('/&#10;/', '', $request);

			$port = $this->config['ssm_port'] ? ':' . $this->config['ssm_port'] : '';
			$path = $this->config['ssm_path'] ? $this->config['ssm_path'] : '';

			$url = $this->config['ssm_host'] . $port . $path;
			// using curl to post the data to the SSM this is a change to the default
			// this is a more secure way than allowing url_open when the SSM is on a different server than the website
			$ch = curl_init($url);
			curl_setopt($ch, CURLOPT_POST, true);
			curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: text/xml'));
			curl_setopt($ch, CURLOPT_POSTFIELDS, $request);
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
			$ssmResponse = curl_exec($ch);
			// preserve curl error if present
			if (curl_error($ch)) {
				$curlError = curl_error($ch);
			}
			curl_close($ch);

			// direct decode of ssmResponse from curl method
			$value = xmlrpc_decode($ssmResponse, 'utf-8');

			if (isset($value['faultCode'])) {
				$result['message'] = "Faultcode : " . $value['faultCode'];
				$result['data'] = $value['faultString'];
			} 
			elseif (isset($value['success'])) {
				if ($value['success'] == true) { //POST: Form submisson correct
					$result['active'] = $value['success'];
					$result['message'] = $value['message'];
				} 
				else { //POST: Submission is not active.
					$result['active'] = $value['success'];
					$result['message'] = $value['message'];
					$result['data'] = $value['errors'];
				}
			} 
			elseif (isset($value['active'])) { //GET: Form is active.
				//Active is true
				if ($value['active'] == true) {
					$result['active'] = true;
					$result['message'] = "form ID";
					$result['data'] = $value['formid'];
				} 
				else {//GET: Form is inactive.
					$result['message'] = $value['message'];
				}
			} 
			elseif (isset ($value['errors'])) { //POST: Incorrect data provided
				$result['active'] = true;
				$result['message'] = "errors";
				$result['data'] = $value['errors'];
			} 
			elseif ($curlError != "") { //Curl encountered an error.
				$result['message'] = "Faultcode : Curl Error";
				$result['data'] = "An error with curl contacting the server. Please enable debug mode for more info.";
				if ($debug) {
					$result['data'] = $curlError;
				}
			} 
			else { //Form encountered an error.
				$result['message'] = "Faultcode : unknown";
				$result['data'] = "An unknown error when contacting the server. Please Check the logs.";
			}
		}
		else {
			$result["message"] = "Faultcode: 999";
			$result["data"] = "The form failed to submit properly, please contact site administrator.";
		}

		return $result;
	}

	public function validateCaptcha() {
		$response = isset($_POST['g-recaptcha-response']) ? $_POST['g-recaptcha-response'] : '';

		if ($response == '') {
			// captcha validation failed
			return false;
		}

		$url = 'https://www.google.com/recaptcha/api/siteverify';
		$secret = $this->config['captcha_secret'];
		$remoteip = $_SERVER['REMOTE_ADDR'];

		$params = array(
			'secret' => $secret,
			'response' => $response,
			'remoteip' => $remoteip
		);

		$ch = curl_init($url);
		curl_setopt($ch, CURLOPT_POST, true);
		// curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: text/xml'));
		curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($params));
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		$response = curl_exec($ch);
		curl_close($ch);

		$response = json_decode($response, true);

		if (isset($response['success']) && $response['success'] == true) {
			// captcha validation passed
			return true;
		} else {
			// captcha validation failed
			return false;
		}
	}
}
$config['site_uuid'] = (isset($_POST['site_name']) ? $site_uuids[$_POST['site_name']] : "");
$config['webroot'] = $_SERVER['DOCUMENT_ROOT'];
$ouldp = new ouldp($config);
$formValidated = true;
if(isset($_POST['form_grc'])){ // obfuscated form field that indictates google reCAPTCHA validation is required.
	$formValidated = $ouldp->validateCaptcha();
}
if($formValidated){
	$form_uuid = (isset($_POST['form_uuid']) ? $_POST['form_uuid'] : "");
	if(!count($_POST)) {
		$func = "ldp.form.enabled";
		$params = array($config['site_uuid'], $form_uuid);
		$result = $ouldp->send($func,$params);
		echo json_encode($result);
	}
	elseif(count($_POST)){
		$func = "ldp.form.submit";
		$ldp_server_ip = "";

		// LOCAL_ADDR when ssm is on a windows server
		if(array_key_exists('SERVER_ADDR', $_SERVER)) {
			$ldp_server_ip = $_SERVER['SERVER_ADDR'];
		}
		elseif(array_key_exists('LOCAL_ADDR', $_SERVER)) {
			$ldp_server_ip = $_SERVER['LOCAL_ADDR'];
		}
		
		$params = array($config['site_uuid'], $form_uuid, $_REQUEST,
						array('OXLDP_FORM_SERVER_NAME'     => $_SERVER['SERVER_NAME'],
							  'OXLDP_FORM_SERVER_IP'       => $ldp_server_ip,
							  'OXLDP_FORM_REQUEST_TIME'    => $_SERVER['REQUEST_TIME'],
							  'OXLDP_FORM_HTTP_HOST'       => $_SERVER['HTTP_HOST'],
							  'OXLDP_FORM_HTTP_REFERER'    => $_SERVER['HTTP_REFERER'],
							  'OXLDP_FORM_HTTP_USER_AGENT' => $_SERVER['HTTP_USER_AGENT'],
							  'OXLDP_FORM_REMOTE_IP'       => 'Not Collected', // Changed to Not Collected to comply with GDPR law. Used to be $_SERVER['REMOTE_ADDR']
							  //'OXLDP_FORM_REMOTE_IP'       => preg_replace('/\.\d+$/', '.x', $_SERVER['REMOTE_ADDR']), // Option for masking the last octet.
							  'OXLDP_FORM_SCRIPT_NAME'     => $_SERVER['SCRIPT_FILENAME'],
							  'OXLDP_FORM_REMOTE_PORT'     => $_SERVER['REMOTE_PORT']));
		$result = $ouldp->send($func,$params);
		echo json_encode($result);
	}
}else{
	echo '{"active":false,"message":"Form did not pass CAPTCHA validation!","data":"","CAPTCHA_FAILED": true}';
}
?>