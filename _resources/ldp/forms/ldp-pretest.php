<!DOCTYPE HTML>
<html lang="en">
	<head>
		<meta charset="utf-8"/>
		<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
		<title>LDP Forms PHP Pretest</title>
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css">
	</head>
	<body>
		<div class="container mt-5 mb-5">
			<div class="masthead">
				<h1 class="text-muted">LDP Forms Pretest</h1>
				<div class="alert alert-success"><strong>Note: </strong>This script is intended to test LDP Forms provided by Omniupdate. This script should be removed after successful configuration.</div>
			</div>
			<div class="card">
				<div class="card-header">
					<h2 class="h5 mb-0">LDP Forms Pretest</h2>
				</div>
				<div class="card-body">
					<h3 class="h4">Required Items</h3>
					<hr>
					<p>The following PHP functions and Server port need to be enabled or open for LDP forms to work properly. Please see the next section for <a href="#file-upload-settings">file upload settings</a>.</p>
					<?php
					echo "<p><strong>Checking Port on SSM </strong>";
						$host = "http://127.0.0.1";
						$ports = array(7518);

						foreach ($ports as $port) {
							$connection = @fsockopen($host, $port);
							if (is_resource($connection)) {
								echo "" . $host . ":" . $port . " is open.";
								fclose($connection);
							}
							else {
								echo $host . ":<strong>" . $port . " is not open.</strong>";
							}
							echo "<br>";
						}

						$passed = array();
						$not_passed = array();

						$functions_array = array("json_encode", "json_decode", "base64_encode", "explode", "end", "strlen", "fopen", "fread", "fclose", "preg_replace", "xmlrpc_encode_request", "xmlrpc_decode", "curl_init", "curl_setopt", "curl_exec", "curl_error", "curl_close");

						function output_helper_test($fun) {
							global $passed;
							global $not_passed;
							$test = function_exists($fun);
							if ($test) {
								array_push($passed, $fun);
							}
							else {
								array_push($not_passed, $fun);
							}
						}

						foreach($functions_array as $item) {
							output_helper_test($item);
						}

					?>
					<div class="card-group mb-3">
						<div class="card bg-light">
							<div class="card-header">Enabled Functions</div>
							<div class="card-body">
								<ul>
								<?php
									foreach($passed as $item) {
										echo "<li>" . $item . "(): enabled</li>";
									}
								?>
							</div>
						</div>
						<div class="card bg-light">
							<div class="card-header">Failed Functions</div>
							<div class="card-body">
								<ul>
								<?php
									foreach($not_passed as $item) {
										echo "<li>" . $item . "(): <strong>NOT enabled</strong></li>";
									}
								?>
							</div>
						</div>
					</div>
					<hr>
					<h3 class="h4 mt-3" id="file-upload-settings">File Upload Settings</h3>
					<hr>
					<p><strong>These items are needed for the file uploads to work correctly. The SSM also requires configuration settings to store uploaded files on a customer-provided S3-type server.</strong> These are the recommended settings for the production server to allow file uploads to the SSM for LDP forms. The recommended settings should at least allow 7 different file uploads to occur for one given form submission. You can increase them or decrease them as desired but this will change the number files that can be uploaded per submission to a different number.</p>
					<div class="card-group mb-3">
						<div class="card bg-light">
							<div class="card-header">Recommended server settings</div>
							<div class="card-body">
								<p class="card-text">These settings are recommended and can be increased or decreased.</p>
								<ul>
									<li>file_uploads = On</li>
									<li>max_file_uploads = 20 (default)</li>
									<li>memory_limit = 300M</li>
									<li>upload_max_filesize = 27M</li>
									<li>post_max_size = 200M</li>
									<li>max_execution_time = 30</li>
								</ul>
							</div>
						</div>
						<div class="card bg-light">
							<div class="card-header">Actual server settings</div>
							<div class="card-body">
								<p class="card-text">Loaded from php.ini: <strong><?php echo php_ini_loaded_file(); ?></strong></p>
								<ul>
								<?php 
									function compare_values($first, $second) {
										$cleaned = preg_replace('/[^0-9]/', '', ini_get($first));
										return ($cleaned < $second) ? "<strong>" . ini_get($first) . " - under recommended value</strong>" : ini_get($first);
									}
									echo "<li>file_uploads = " . (ini_get("file_uploads") == 1 ? "On" : "<strong>Off</strong>") . "</li>".PHP_EOL;
									echo "<li>max_file_uploads = " . compare_values("max_file_uploads", 20) . "</li>".PHP_EOL;
									echo "<li>memory_limit = " . compare_values("memory_limit", 300) . "</li>".PHP_EOL;
									echo "<li>upload_max_filesize = " . compare_values("upload_max_filesize", 27) . "</li>".PHP_EOL;
									echo "<li>post_max_size = " . compare_values("post_max_size", 200)  . "</li>".PHP_EOL;
									echo "<li>max_execution_time = " . compare_values("max_execution_time", 30) . "</li>".PHP_EOL;
								?>
								</ul>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>