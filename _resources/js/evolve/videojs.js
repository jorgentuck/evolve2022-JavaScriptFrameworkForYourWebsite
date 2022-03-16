//  run once page is ready
$(document).ready(function () {
  // Select video by id
  const player = videojs('my-video');

  // select p element that we want the buttons to come after
  const p = $('div.container p');

  // add buttons - since we are adding them after the last button added will be the first in the row
  p.after(`<button class="btn-dark playbackToggle">Add Additional Playback Rates</button>  `);
  p.after(`<button class="btn-dark controlToggle">Hide Controls</button>  `);
  p.after(`<button class="btn-dark muteToggle">Unmute</button>  `);
  p.after(`<button class="btn-dark languageToggle">Toggle Spanish Controls</button>  `);

  // add spanish translations
  videojs.addLanguage('es', {
    Play: 'Reproducir',
    'Play Video': 'Reproducir Vídeo',
    Pause: 'Pausa',
    'Current Time': 'Tiempo reproducido',
    Duration: 'Duración total',
    'Remaining Time': 'Tiempo restante',
    'Stream Type': 'Tipo de secuencia',
    LIVE: 'DIRECTO',
    Loaded: 'Cargado',
    Progress: 'Progreso',
    Fullscreen: 'Pantalla completa',
    'Non-Fullscreen': 'Pantalla no completa',
    Mute: 'Silenciar',
    Unmute: 'No silenciado',
    'Playback Rate': 'Velocidad de reproducción',
    Subtitles: 'Subtítulos',
    'subtitles off': 'Subtítulos desactivados',
    Captions: 'Subtítulos especiales',
    'captions off': 'Subtítulos especiales desactivados',
    Chapters: 'Capítulos',
    'You aborted the media playback': 'Ha interrumpido la reproducción del vídeo.',
    'A network error caused the media download to fail part-way.': 'Un error de red ha interrumpido la descarga del vídeo.',
    'The media could not be loaded, either because the server or network failed or because the format is not supported.': 'No se ha podido cargar el vídeo debido a un fallo de red o del servidor o porque el formato es incompatible.',
    'The media playback was aborted due to a corruption problem or because the media used features your browser did not support.': 'La reproducción de vídeo se ha interrumpido por un problema de corrupción de datos o porque el vídeo precisa funciones que su navegador no ofrece.',
    'No compatible source was found for this media.': 'No se ha encontrado ninguna fuente compatible con este vídeo.',
    'Audio Player': 'Reproductor de audio',
    'Video Player': 'Reproductor de video',
    Replay: 'Volver a reproducir',
    'Seek to live, currently behind live': 'Buscar en vivo, actualmente demorado con respecto a la transmisión en vivo',
    'Seek to live, currently playing live': 'Buscar en vivo, actualmente reproduciendo en vivo',
    'Progress Bar': 'Barra de progreso',
    'progress bar timing: currentTime={1} duration={2}': '{1} de {2}',
    Descriptions: 'Descripciones',
    'descriptions off': 'descripciones desactivadas',
    'Audio Track': 'Pista de audio',
    'Volume Level': 'Nivel de volumen',
    'The media is encrypted and we do not have the keys to decrypt it.': 'El material audiovisual está cifrado y no tenemos las claves para descifrarlo.',
    Close: 'Cerrar',
    'Modal Window': 'Ventana modal',
    'This is a modal window': 'Esta es una ventana modal',
    'This modal can be closed by pressing the Escape key or activating the close button.': 'Esta ventana modal puede cerrarse presionando la tecla Escape o activando el botón de cierre.',
    ', opens captions settings dialog': ', abre el diálogo de configuración de leyendas',
    ', opens subtitles settings dialog': ', abre el diálogo de configuración de subtítulos',
    ', selected': ', seleccionado',
    'Close Modal Dialog': 'Cierra cuadro de diálogo modal',
    ', opens descriptions settings dialog': ', abre el diálogo de configuración de las descripciones',
    'captions settings': 'configuración de leyendas',
    'subtitles settings': 'configuración de subtítulos',
    'descriptions settings': 'configuración de descripciones',
    Text: 'Texto',
    White: 'Blanco',
    Black: 'Negro',
    Red: 'Rojo',
    Green: 'Verde',
    Blue: 'Azul',
    Yellow: 'Amarillo',
    Magenta: 'Magenta',
    Cyan: 'Cian',
    Background: 'Fondo',
    Window: 'Ventana',
    Transparent: 'Transparente',
    'Semi-Transparent': 'Semitransparente',
    Opaque: 'Opaca',
    'Font Size': 'Tamaño de fuente',
    'Text Edge Style': 'Estilo de borde del texto',
    None: 'Ninguno',
    Raised: 'En relieve',
    Depressed: 'Hundido',
    Uniform: 'Uniforme',
    Dropshadow: 'Sombra paralela',
    'Font Family': 'Familia de fuente',
    'Proportional Sans-Serif': 'Sans-Serif proporcional',
    'Monospace Sans-Serif': 'Sans-Serif monoespacio',
    'Proportional Serif': 'Serif proporcional',
    'Monospace Serif': 'Serif monoespacio',
    Casual: 'Informal',
    Script: 'Cursiva',
    'Small Caps': 'Minúsculas',
    Reset: 'Restablecer',
    'restore all settings to the default values': 'restablece todas las configuraciones a los valores predeterminados',
    Done: 'Listo',
    'Caption Settings Dialog': 'Diálogo de configuración de leyendas',
    'Beginning of dialog window. Escape will cancel and close the window.': 'Comienzo de la ventana de diálogo. La tecla Escape cancelará la operación y cerrará la ventana.',
    'End of dialog window.': 'Final de la ventana de diálogo.',
    '{1} is loading.': '{1} se está cargando.',
    'Exit Picture-in-Picture': 'Salir de imagen sobre imagen',
    'Picture-in-Picture': 'Imagen sobre imagen',
  });

  // Add/Remove extra playback rates
  $('body').on('click', 'button.playbackToggle', function () {
    player.playbackRates().length == 0 ? $(this).text('Remove Additional Playback Rates') : $(this).text('Add Additional Playback Rates');
    player.playbackRates().length == 0 ? player.playbackRates([0.5, 1, 1.5, 2]) : player.playbackRates([]);
    player.playbackRates().length == 0 ? console.log(true) : console.log(false);
  });

  // Show/Hide video controls
  $('body').on('click', 'button.controlToggle', function () {
    player.controls() ? $(this).text('Show Controls') : $(this).text('Hide Controls');
    player.controls() ? player.controls(false) : player.controls(true);
  });

  // Mute/Unmute Video
  $('body').on('click', 'button.muteToggle', function () {
    player.muted() ? $(this).text('Mute') : $(this).text('Unmute');
    player.muted() ? player.muted(false) : player.muted(true);
  });

  // Toggle language between Spanish and English
  $('body').on('click', 'button.languageToggle', function () {
    player.language() == 'en' ? $(this).text('Toggle English Controls') : $(this).text('Toggle Spanish Controls');
    player.language() == 'en' ? player.language('es') : player.language('en');
  });

	// autoplay the video on mute after waiting 100 ms
	setTimeout(function(){
		player.autoplay('muted');
	}, 100);

});
