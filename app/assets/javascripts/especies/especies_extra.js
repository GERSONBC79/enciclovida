$(document).ready(function () {

    $('#navegacion a.load-tab').one('click', function () {
        var idPestaña = $(this).data('params') || this.getAttribute('href').replace('#','');
        var pestaña = '/especies/' + opciones.taxon + '/'+idPestaña;

        $(this.getAttribute('href')).load(pestaña, function () {
            switch (idPestaña) {
                case 'media':
                    $('#mediaBDI_p').load('/especies/' + opciones.taxon + '/bdi-photos?type=photo', function () {
                        $(this).removeClass("d-none");  // Esta es la unica que se queda si no hay contenido, para que puedan aportar fotos
                    });

                    if (opciones.ancestry.includes(",22655,")) {  // Si es una ave
                        $("#xenocanto").load('/especies/' + opciones.taxon + "/xeno-canto?type=audio", function () {
                            if ($(this).html() != "") $(this).removeClass("d-none");
                        });
                    }

                    // $('#mediaBDI_v').load('/especies/' + opciones.taxon + '/bdi-videos?type=video', function () {
                    // });                    
                    $('#mediaCornell_p').load('/especies/' + opciones.taxon + '/media-cornell?type=photo', function () {
                        if($(this).html() != "") $(this).removeClass("d-none");
                    });

                    $('#mediaCornell_v').load('/especies/' + opciones.taxon + '/media-cornell?type=video', function () {
                        if($(this).html() != "") $(this).removeClass("d-none");
                    });

                    $('#mediaCornell_a').load('/especies/' + opciones.taxon + '/media-cornell?type=audio', function () {
                        if($(this).html() != "") $(this).removeClass("d-none");
                    });

                    if (opciones.ancestry.includes(",2,")) {  // Si es una planta
                        $('#mediaTropicos').load('/especies/' + opciones.taxon + '/media-tropicos', function () {
                            if ($(this).html() != "") $(this).removeClass("d-none"); 
                        });
                    }
                            
                    break;
                case 'descripcion_catalogos':
                    $('.biblio-cat').popover({html: true});
                    break;
                default:
                    break;
            }
        });

    });
    if (opciones.naturalista_api != undefined) fotosNaturalista(); else fotosBDI();

    $('#nombres_comunes_todos').load("/especies/" + opciones.taxon + "/nombres-comunes-todos");

    $('#enlaces_externos').on('click', '#boton_pdf', function(){
        window.open("/especies/" + opciones.taxon + ".pdf?from=" + opciones.cual_ficha);
    });

    $(document).on('click', '.historial_ficha', function(){
        var comentario_id = $(this).attr('comentario_id');
        var especie_id = $(this).attr('especie_id');
        $("#historial_ficha_" + comentario_id).load("/especies/" + especie_id + "/comentarios/" + comentario_id + "/respuesta_externa?ficha=1");
        $("#historial_ficha_" + comentario_id).slideDown();
        return false;
    });
    $("html,body").animate({scrollTop: 101}, 500);

    $('#media, #contenedor_fotos, #arbol').on('click','.paginado-media button:first-of-type, #especies-destacadas button:first-of-type',function(){
        $(this).parent().animate({scrollLeft: "-=400px"}, 200);
    });
    $('#media, #contenedor_fotos, #arbol').on('click','.paginado-media button:last-of-type, #especies-destacadas button:last-of-type',function(){
        $(this).parent().animate({scrollLeft: "+=400px"}, 200);
    });

    $('#modal_clasificacion_completa').on('show.bs.modal', function (event) {
        var button = $(event.relatedTarget);
        var taxonId = button.data('taxon-id');
        var modalBody = $(this).find('.modal-body');
        modalBody.empty();
        modalBody.load('/explora-por-clasificacion?especie_id='+taxonId+'&fromShow=1');
    }).on('click', '.nodo-taxon', function (){
        despliegaOcontrae(this);
    });

});
