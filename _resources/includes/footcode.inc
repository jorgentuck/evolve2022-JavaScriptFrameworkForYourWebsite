<!-- jQuery CDN -->
<script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
<script src="/_resources/js/bootstrap.js"></script>
<script src="/_resources/js/scripts.js"></script>
<script src="/_resources/js/slick-lightbox.js"></script>
<script src="/_resources/js/slick.min.js"></script>
<script src="/_resources/js/lightbox.js"></script>
<!--Data Sort Tables JS-->
<script src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.10.20/js/dataTables.bootstrap4.min.js"></script>
<script>
	$(document).ready(function() {
		$('#directory-list').DataTable( {
			"pageLength": 25,
			"order": [[ 1, "asc" ]]
		} );
	} );
</script>

<!-- Voca.js -->
<script src="/_resources/js/evolve/voca.js" type="text/javascript"></script>

<!-- Video.js CDN -->
<script src="https://vjs.zencdn.net/7.17.0/video.min.js"></script>

<!-- Sharect.js CDN -->
<script src="https://unpkg.com/sharect@2.0.0/dist/sharect.js"></script>

<!-- Sharect.js cofig file -->
<script src="/_resources/js/evolve/sharect-config.js" type="text/javascript"></script>