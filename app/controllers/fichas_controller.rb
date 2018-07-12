class FichasController < ApplicationController

  #  - - - - - - - - * * Rutas de información de especie (Según su id) * *  - - - - - - - -
  # Clasificación y descripción de la especie
  def clasificacion_y_descripcion_de_especie # especieId

    # taxon: Obtener el id de la especie
    @taxon = Taxon.find(params[:id])
    @nombre_comun = @taxon.nombreComun
    @legislacion = @taxon.legislaciones.first
    @sinonimo = @taxon.sinonimos.first

    render json: {
        taxon: @taxon,
        nombre_comun: @nombre_comun,
        legislacion: @legislacion,
        sinonimo: @sinonimo
    }
  end


  # Distribución de la especie
  def distribucione_de_la_especie # especieId

    @taxon = Taxon.find(params[:id])
    @distribucion = @taxon.distribuciones.first
    @endemica = @taxon.endemicas.first
    @habitat = @taxon.habitats.first

    render json: {
        taxon: @taxon,
        distribucion: @distribucion,
        endemica: @endemica,
        habitat: @habitat
    }
  end


  # Tipo de ambiente en donde se desarrolla la especie
  def ambiente_de_desarrollo_de_especie

    @taxon = Taxon.find(params[:id])
    @habitat = @taxon.habitats.first
    @tipoClima = @habitat.tipoclima
    @suelo = @habitat.suelo
    @geoforma = @habitat.geoforma
    @ecorregion = @habitat.ecorregion.first
    @ecosistema = @habitat.ecosistema.first
    #@cat_eacorregionwwf = Cat_Ecorregionwwf.find_by(IdEcorregion: @ecorregion.ecorregionId)
    @habitatAntropico = @habitat.habitatAntropico

    render json: {
        taxon: @taxon,
        habitat: @habitat,
        tipoClima: @tipoClima,
        suelo: @suelo,
        geoforma: @geoforma,
        ecorregion: @ecorregion,
        ecosistema: @ecosistema,
        habitatAntropico: @habitatAntropico
    }
  end

  # IV. Biología de la especie
  def biologia_de_la_especie

    @taxon = Taxon.find(params[:id]) # Obtener el id de especie
    @habitat = @taxon.habitats.first
    @historiaNatural = @taxon.historiaNatural
    @demografiaAmenazas = @taxon.demografiaAmenazas.first
    @infoReproduccion = @historiaNatural.get_info_reproduccion

    render json: {
        taxon: @taxon,
        habitat: @habitat,
        historiaNatural: @historiaNatural,
        demografiaamenazas: @demografiaamenazas,
        infoReproduccion: @infoReproduccion
    }
  end

  # V. Ecología y demografía de la especie
  def ecologia_y_demografia_de_especie

    @taxon = Taxon.find(params[:id]) # Obtener el id de especie
    @demograAmenazas = @taxon.demografiaAmenazas.first
    @interaccion = @demograAmenazas.interaccion

    render json: {
        taxon: @taxon,
        demograAmenazas: @demograAmenazas,
        interaccion: @interaccion
    }
  end

  # VI. Genética de la especie
  def genetica_de_especie

    taxon = Taxon.find(params[:id]) # Obtener el id de especie
    @historianatural = taxon.historiaNatural

    render json: {
        historianatural: @historianatural
    }
  end

  # VII. Importancia de la especie
  def importancia_de_especie

    taxon = Taxon.find(params[:id]) # Obtener el id de especie
    @historiaNatural = taxon.historiaNatural
    @culturaUsos = @historiaNatural.culturaUsos

    render json: {
        historianatural: @historianatural,
        culturaUsos: @culturaUsos
    }
  end

  # VIII. Estado de conservación de la especie
  def estado_de_conservacion_de_especie

    taxon = Taxon.find(params[:id]) # Obtener el id de especie

    @conservacion = taxon.conservacion.first
    @demografiaAmenazas = taxon.demografiaAmenazas.first
    @amenazaDirecta = @demografiaAmenazas.amenazaDirecta.first

    render json: {
        amenazaDirecta: @amenazaDirecta,
        demografiaAmenazas: @demografiaAmenazas,
        conservacion: @conservacion
    }
  end

  # IX. Especies prioritarias para la conservación
  def especies_prioritarias_para_conservacion

    @taxon = Taxon.find(params[:id]) # Obtener el id de especie

    render json: { taxon: @taxon }
  end

  # X. Necesidades de información
  def necesidades_de_informacion

    @taxon = Taxon.find(params[:id]) # Obtener el id de especie

    render json: { taxon: @taxon }
  end


  def informacion_de_especie
    # Acceso a la especie:
    @taxon = Taxon.find(params[:id])  # Obtener el id de especie


    # A partir de la especie, acceder a:
    # I. Clasificación y descripción de la especie
    @nombre_comun = @taxon.nombreComun
    @legislacion = @taxon.legislaciones.first
    @sinonimo = @taxon.sinonimos.first

    # II. Distribución de la especie
    @distribucion = @taxon.distribuciones.first
    @endemica = @taxon.endemicas.first
    @habitat = @taxon.habitats.first

    # III. Tipo de ambiente en donde se desarrolla la especie
    #@habitat = @taxon.habitats.first
    @tipoClima = @habitat.tipoclima
    @suelo = @habitat.suelo
    @geoforma = @habitat.geoforma
    @ecorregion = @habitat.ecorregion.first
    @ecosistema = @habitat.ecosistema.first
    #@cat_eacorregionwwf = Cat_Ecorregionwwf.find_by(IdEcorregion: @ecorregion.ecorregionId)
    @habitatAntropico = @habitat.habitatAntropico

    # IV. Biología de la especie
    #@habitat = @taxon.habitats.first
    @historiaNatural = @taxon.historiaNatural
    @demografiaAmenazas = @taxon.demografiaAmenazas.first
    @infoReproduccion = @historiaNatural.get_info_reproduccion

    # V. Ecología y demografía de la especie
    #@demograAmenazas = @taxon.demografiaAmenazas.first
    @interaccion = @demografiaAmenazas.interaccion

    # VI. Genética de la especie
    # @historianatural = taxon.historiaNatural

    # VII. Importancia de la especie
    #@historiaNatural = taxon.historiaNatural
    @culturaUsos = @historiaNatural.culturaUsos.first

    # VIII. Estado de conservación de la especie
    @conservacion = @taxon.conservacion.first
    #@demografiaAmenazas = @taxon.demografiaAmenazas.first
    @amenazaDirecta = @demografiaAmenazas.amenazaDirecta.first

    # IX. Especies prioritarias para la conservación
    # @taxon = Taxon.find(params[:id])

    # X. Necesidades de información
    # @taxon = Taxon.find(params[:id])


    respond_to do |format|
      format.html #{ render :layout => false }
      format.json { render json: {
          taxon: @taxon,
          # I. Clasificación y descripción de la especie
          nombre_comun: @nombre_comun, legislacion: @legislacion, sinonimo: @sinonimo,
          # II. Distribución de la especie
          distribucion: @distribucion, endemica: @endemica, habitat: @habitat,
          # III. Tipo de ambiente en donde se desarrolla la especie
          tipoClima: @tipoClima, suelo: @suelo, geoforma: @geoforma, ecorregion: @ecorregion, ecosistema: @ecosistema, cat_eacorregionwwf: @cat_eacorregionwwf,
          # IV. Biología de la especie
          historiaNatural: @historiaNatural, demografiaamenazas: @demografiaamenazas, infoReproduccion: @infoReproduccion,
          # V. Ecología y demografía de la especie
          interaccion: @interaccion,
          # VI. Genética de la especie
          # VII. Importancia de la especie
          culturaUsos: @culturaUsos,
          # VIII. Estado de conservación de la especie
          amenazaDirecta: @amenazaDirecta, conservacion: @conservacion
          # IX. Especies prioritarias para la conservación
          # X. Necesidades de información
        }
      }
    end
  end

end
