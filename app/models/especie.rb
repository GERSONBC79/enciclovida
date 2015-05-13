# coding: utf-8
class Especie < ActiveRecord::Base

  self.table_name='especies'
  self.primary_key='id'

  has_one :proveedor
  has_one :adicional
  belongs_to :categoria_taxonomica
  has_many :especies_regiones, :class_name => 'EspecieRegion', :foreign_key => 'especie_id', :dependent => :destroy
  has_many :especies_catalogos, :class_name => 'EspecieCatalogo', :dependent => :destroy
  has_many :nombres_regiones, :class_name => 'NombreRegion', :dependent => :destroy
  has_many :nombres_regiones_bibliografias, :class_name => 'NombreRegionBibliografia', :dependent => :destroy
  has_many :especies_estatus, :class_name => 'EspecieEstatus', :foreign_key => :especie_id1, :dependent => :destroy
  has_many :especies_bibliografias, :class_name => 'EspecieBibliografia', :dependent => :destroy
  has_many :taxon_photos, :order => 'position ASC, id ASC', :dependent => :destroy
  has_many :photos, :through => :taxon_photos
  has_many :nombres_comunes, :through => :nombres_regiones, :source => :nombre_comun
  has_many :tipos_distribuciones, :through => :especies_regiones, :source => :tipo_distribucion
  has_many :estados_conservacion, :through => :especies_catalogos, :source => :catalogo
  has_many :metadatos_especies, :class_name => 'MetadatoEspecie', :foreign_key => 'especie_id'
  has_many :metadatos, :through => :metadatos_especies#, :source => :metadato

  has_ancestry :ancestry_column => :ancestry_ascendente_directo

  accepts_nested_attributes_for :especies_catalogos, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :especies_regiones, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :nombres_regiones, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :nombres_regiones_bibliografias, :reject_if => :all_blank, :allow_destroy => true

  scope :caso_insensitivo, ->(columna, valor) { where("LOWER(#{columna}) LIKE LOWER('%#{valor}%')") }
  scope :caso_empieza_con, ->(columna, valor) { where("#{columna} LIKE '#{valor}%'") }
  scope :caso_sensitivo, ->(columna, valor) { where("#{columna}='#{valor}'") }
  scope :caso_termina_con, ->(columna, valor) { where("#{columna} LIKE '%#{valor}'") }
  scope :caso_fecha, ->(columna, valor) { where("CAST(#{columna} AS TEXT) LIKE '%#{valor}%'") }
  scope :caso_ids, ->(columna, valor) { where(columna => valor) }
  scope :caso_rango_valores, ->(columna, rangos) { where("#{columna} IN (#{rangos})") }
  scope :caso_status, ->(status) { where(:estatus => status.to_i) }
  scope :ordenar, ->(columna, orden) { order("#{columna} #{orden}") }

  #Los joins explicitos fueron necesarios ya que por default "joins", es un RIGHT JOIN
  scope :especies_regiones_join, -> { joins('LEFT JOIN especies_regiones ON especies_regiones.especie_id=especies.id') }
  scope :nombres_comunes_join, -> { joins('LEFT JOIN nombres_regiones ON nombres_regiones.especie_id=especies.id').
      joins('LEFT JOIN nombres_comunes ON nombres_comunes.id=nombres_regiones.nombre_comun_id') }
  scope :region_join, -> { joins('LEFT JOIN regiones ON regiones.id=especies_regiones.region_id') }
  scope :tipo_region_join, -> { joins('LEFT JOIN tipos_regiones ON tipos_regiones.id=regiones.tipo_region_id') }
  scope :tipo_distribucion_join, -> { especies_regiones_join.joins('LEFT JOIN tipos_distribuciones ON tipos_distribuciones.id=especies_regiones.tipo_distribucion_id') }
  scope :caso_nombre_bibliografia, -> { joins('LEFT JOIN nombres_regiones_bibliografias ON nombres_regiones_bibliografias.especie_id=especie.id').
      joins('LEFT JOIN bibliografias ON bibliografias.id=nombres_regiones_bibliografias.bibliografia_id') }
  scope :catalogos_join, -> { joins('LEFT JOIN especies_catalogos ON especies_catalogos.especie_id=especies.id').
      joins('LEFT JOIN catalogos ON catalogos.id=especies_catalogos.catalogo_id') }
  scope :categoria_taxonomica_join, -> { joins('LEFT JOIN categorias_taxonomicas ON categorias_taxonomicas.id=especies.categoria_taxonomica_id') }
  scope :adicionales, -> { joins('LEFT JOIN adicionales ON adicionales.especie_id=especies.id') }
  scope :datos, -> { joins('LEFT JOIN especies_regiones ON especies.id=especies_regiones.especie_id').joins('LEFT JOIN categoria_taxonomica') }


  POR_PAGINA = [100, 200, 500, 1000]
  POR_PAGINA_PREDETERMINADO = POR_PAGINA.first

  CON_REGION = [19, 50]
  ESTATUS = [
      [2, 'válido'],
      [1, 'sinónimo']
  ]

  ESTATUS_VALOR = {
      ESTATUS[0][0] => ESTATUS[0][1],
      ESTATUS[1][0] => ESTATUS[1][1]
  }

  ESTATUS_SIMBOLO = {
      2 => '',
      1 =>''
  }

  ESTATUS_SIGNIFICADO = {
      2 => 'válido',
      1 =>'sinónimo'
  }

  ESPECIES_Y_MENORES = %w(19 20 21 22 23 24 50 51 52 53 54 55)

  BUSQUEDAS_TEXTO = {
      1 => 'contiene',
      2 => 'empieza con',
      3 => 'igual a',
      4 => 'termina con'
  }

  BUSQUEDAS_ATRIBUTO = {
      'nombre_cientifico' => 'nombre científico',
      'nombre_comun' => 'nombre común',
      'catalogos.descripcion' => 'característica del taxón',
      'nombre_autoridad' => 'autoridad'
  }

  BUSQUEDAS_COMPARADOR = {
      '>' => 'menor a',
      '>=' => 'menor o igual a',
      '=' => 'igual a',
      '<=' => 'mayor o igual a',
      '<' => 'mayor a'
  }

  NIVEL_CATEGORIAS = [
      ['inferior o igual a', '>='],
      ['inferior a', '>'],
      ['igual a', '='],
      ['superior o igual a', '<='],
      ['superior a', '<']
  ]

  SPECIES_OR_LOWER = %w(especie subespecie variedad subvariedad forma subforma)
  BAJO_GENERO = %w(género subgénero sección subsección serie subserie)

  def self.por_categoria(busqueda, distinct = false)
    # Las condiciones y el join son los mismos pero cambia el select
    sql = "select('CONCAT(categorias_taxonomicas.nivel1,categorias_taxonomicas.nivel2,categorias_taxonomicas.nivel3,categorias_taxonomicas.nivel4) AS nivel,"
    sql << 'nombre_categoria_taxonomica,'

    if distinct
      sql << 'count(DISTINCT especies.id) as cuantos'
    else
      sql << 'count(CONCAT(categorias_taxonomicas.nivel1,categorias_taxonomicas.nivel2,categorias_taxonomicas.nivel3,categorias_taxonomicas.nivel4)) as cuantos'
    end

    sql << "')"

    busq = busqueda.sub(/select\(.+mica'\)/, sql)
    busq << ".group('CONCAT(categorias_taxonomicas.nivel1,categorias_taxonomicas.nivel2,categorias_taxonomicas.nivel3,categorias_taxonomicas.nivel4), nombre_categoria_taxonomica')"
    busq << ".order('nivel')"

    if distinct
      query_limpio = Bases.distinct_limpio(eval(busq).to_sql)
      query_limpio << ' ORDER BY nivel ASC'
      Especie.find_by_sql(query_limpio)
    else
      eval(busq)
    end
  end

  def self.por_arbol(busqueda, sin_filtros=false)
    if sin_filtros #La búsqueda que realizaste no contiene filtro alguno
      sql = 'select("especies.id, nombre_cientifico, ancestry_ascendente_directo, ancestry_ascendente_directo+\'/\'+cast(especies.id as nvarchar) as arbol, categoria_taxonomica_id, categorias_taxonomicas.nombre_categoria_taxonomica, nombre_autoridad, estatus, icono, nombre_icono")'
      busq = busqueda.sub(/select\(.+mica'\)/, sql)
      busq = busq.sub(/\.where\(\"CONCAT.+/,'')
      busq << ".order('arbol')"
      eval(busq)
    else # Las condiciones y el join son los mismos pero cambia el select, para desplegar el checklist
      sql = 'select("ancestry_ascendente_directo+\'/\'+cast(especies.id as nvarchar) as arbol")'
      busq = busqueda.sub(/select\(.+mica'\)/, sql)
      eval(busq)
    end
  end

  # Override assignment method provided by has_many to ensure that all
  # callbacks on photos and taxon_photos get called, including after_destroy
  def photos=(new_photos)
    taxon_photos.each do |taxon_photo|
      taxon_photo.destroy unless new_photos.detect{|p| p.id == taxon_photo.photo_id}
    end
    new_photos.each do |photo|
      taxon_photos.build(:photo => photo) unless photos.detect{|p| p.id == photo.id}
    end
  end

  def species_or_lower?(cat=nil, con_genero=false)
    if con_genero
      SPECIES_OR_LOWER.include?(cat || categoria_taxonomica.nombre_categoria_taxonomica) || BAJO_GENERO.include?(cat || categoria_taxonomica.nombre_categoria_taxonomica)
    else
      SPECIES_OR_LOWER.include?(cat || categoria_taxonomica.nombre_categoria_taxonomica)
    end
  end

  #
  # Fetches associated user-selected FlickrPhotos if they exist, otherwise
  # gets the the first :limit Create Commons-licensed photos tagged with the
  # taxon's scientific name from Flickr.  So this will return a heterogeneous
  # array: part FlickrPhotos, part api responses
  #
  def photos_with_backfill(options = {})
    options[:limit] ||= 9
    chosen_photos = taxon_photos.includes(:photo).limit(options[:limit]).map{|tp| tp.photo}
    if chosen_photos.size < options[:limit]
      new_photos = Photo.includes({:taxon_photos => :especie}).
          order("taxon_photos.id ASC").
          limit(options[:limit] - chosen_photos.size).
          where("especies.ancestry_ascendente_directo LIKE '#{ancestry_ascendente_directo}/#{id}%'")#.includes()
      if new_photos.size > 0
        new_photos = new_photos.where("photos.id NOT IN (?)", chosen_photos)
      end
      chosen_photos += new_photos.to_a
    end
    flickr_chosen_photos = []
    if !options[:skip_external] && chosen_photos.size < options[:limit] && self.auto_photos
      begin
        r = flickr.photos.search(
            :tags => name.gsub(' ', '').strip,
            :per_page => options[:limit] - chosen_photos.size,
            :license => '1,2,3,4,5,6', # CC licenses
            :extras => 'date_upload,owner_name,url_s,url_t,url_s,url_m,url_l,url_o,owner_name,license',
            :sort => 'relevance'
        )
        r = [] if r.blank?
        flickr_chosen_photos = if r.respond_to?(:map)
                                 r.map{|fp| fp.respond_to?(:url_s) && fp.url_s ? FlickrPhoto.new_from_api_response(fp) : nil}.compact
                               else
                                 []
                               end
      rescue FlickRaw::FailedResponse, EOFError => e
        Rails.logger.error "EXCEPTION RESCUE: #{e}"
        Rails.logger.error e.backtrace.join("\n\t")
      end
    end
    flickr_ids = chosen_photos.map{|p| p.native_photo_id}
    chosen_photos += flickr_chosen_photos.reject do |fp|
      flickr_ids.include?(fp.id)
    end
    chosen_photos
  end

  def photos_cache_key
    "taxon_photos_#{id}"
  end

  def photos_with_external_cache_key
    "taxon_photos_external_#{id}"
  end

  def info_tab_cache_key
    "views/info_tab_#{id}"
  end

  # Guarda en cache el path del KMZ
  def snib_cache_key
    "snib_#{id}"
  end

  def completa_blurrily
    FUZZY_NOM_CIEN.put(nombre_cientifico, id)
  end

  def exporta_redis
    return unless ad = adicional

    data = ''
    data << "{\"id\":#{id},"
    data << "\"term\":\"#{nombre_cientifico}\","
    data << "\"data\":{\"nombre_comun\":\"#{ad.nombre_comun_principal.try(:limpia)}\", "
    data <<  "\"nombre_icono\":\"#{ad.nombre_icono}\", \"icono\":\"#{ad.icono}\", \"color\":\"#{ad.color_icono}\", "
    data << "\"autoridad\":\"#{nombre_autoridad.limpia}\", \"id\":#{id}, \"estatus\":\"#{Especie::ESTATUS_VALOR[estatus]}\"}"
    data << "}\n"
  end

  def cat_tax_asociadas
    limites = Bases.limites(id)
    rama = %w(0)

    # Quiere decir que es con las categorias de phylum, clasificadas por el nivel2
    if ancestry_ascendente_directo.include?('1000001') || id == 1000001
      rama = %w(1 2)
    end

    if I18n.locale.to_s == 'es-cientifico'
      CategoriaTaxonomica.select('id,nombre_categoria_taxonomica,CONCAT(nivel1,nivel2,nivel3,nivel4) as nivel').
          where(:id => limites[:limite_inferior]..limites[:limite_superior]).where("nivel2 IN (#{rama.join(',')}) OR nombre_categoria_taxonomica='Reino'").order('nivel')
    else # Con las categorias de division
      CategoriaTaxonomica.select('id,nombre_categoria_taxonomica,CONCAT(nivel1,nivel2,nivel3,nivel4) as nivel').
          where(:id => limites[:limite_inferior]..limites[:limite_superior]).
          caso_rango_valores('nombre_categoria_taxonomica', CategoriaTaxonomica::CATEGORIAS_OBLIGATORIAS.map{|c| "'#{c}'"}.join(',')).
          where("nivel2 IN (#{rama.join(',')}) OR nombre_categoria_taxonomica='Reino'").order('nivel')
    end
  end

  def asigna_nombre_comun
    if adicional
      return if adicional.nombre_comun_principal.present?
      adicional.pon_nombre_comun_principal
    else
      ad = crea_con_nombre_comun
      return {:cambio => ad.nombre_comun_principal.present?, :adicional => ad}
    end

    {:cambio => adicional.nombre_comun_principal_changed?, :adicional => adicional}
  end

  # Pone el nombre comun principal en la tabla adicionales
  def crea_con_nombre_comun
    ad = Adicional.new
    ad.especie_id = id
    ad.nombre_comun_principal = ad.pon_nombre_comun_principal
    ad
  end

  def self.asigna_grupo_iconico
    Adicional::GRUPOS_ICONICOS.keys.each do |grupo|
      puts grupo
      reinos_grandes = %w(Animalia Plantae)
      taxon = Especie.where(:nombre_cientifico => grupo).first
      puts "Hubo un error al buscar el taxon: #{grupo}" unless taxon

      if reinos_grandes.include?(grupo)  # Los corro aparte para no volver a sobreescribir el valor
        taxones_default = Especie.adicionales.
            where("ancestry_ascendente_directo='#{taxon.id}' OR ancestry_ascendente_directo LIKE '#{taxon.id}/%' OR nombre_cientifico='#{grupo}'").
            where('adicionales.icono IS NULL')

        taxones_default.find_each do |taxon_default|
          puts "Descendiente de #{grupo}: #{taxon_default.id}"

          begin
            t = Especie.find(taxon_default.id)
          rescue
            next
          end

          if t.adicional
            t.adicional.pon_grupo_iconico(grupo)
          else
            ad = t.crea_con_grupo_iconico(grupo)
            ad.save
            next
          end

          if t.adicional.icono_changed? || t.adicional.nombre_icono_changed? || t.adicional.color_icono_changed?
            t.adicional.save
          end
        end

      else
        descendientes = taxon.subtree_ids
        descendientes.each do |descendiente| # Itero sobre los descendientes
          puts "Descendiente de #{grupo}: #{descendiente}"

          begin
            t = Especie.find(descendiente)
          rescue
            next
          end

          if t.adicional
            t.adicional.pon_grupo_iconico(grupo)
          else
            ad = t.crea_con_grupo_iconico(grupo)
            ad.save
            next
          end

          if t.adicional.icono_changed? || t.adicional.nombre_icono_changed? || t.adicional.color_icono_changed?
            t.adicional.save
          end
        end  # Cierra el each
      end

    end  # Cierra el iterador de grupos
  end

  # Pone el grupo iconico en la tabla adicionales
  def crea_con_grupo_iconico(grupo)
    ad = Adicional.new
    ad.especie_id = id
    ad.pon_grupo_iconico(grupo)
    ad
  end

  # Pone la foto principal en la tabla adicionales
  def asigna_foto
    # Pone la primera foto que encuentre con NaturaLista, de lo contrario una de CONABIO
    foto_p = if fotos = photos.where("photos.type != 'ConabioPhoto'")
                       fotos.first.thumb_url if fotos.any?
                     elsif fotos= photos.where("photos.type = 'ConabioPhoto'")
                       fotos.first.thumb_url if fotos.any?
                     end

    return {:cambio => false} unless photos.any?

    if adicional
      return {:cambio => false} if adicional.foto_principal.present?
      adicional.foto_principal = foto_p
    else
      ad = crea_con_foto(foto_p)
      return {:cambio => ad.foto_principal.present?, :adicional => ad}
    end

    {:cambio => adicional.foto_principal_changed?, :adicional => adicional}
  end

  # Pone la foto principal en la tabla adicionales
  def crea_con_foto(foto_principal)
    ad = Adicional.new
    ad.especie_id = id
    ad.foto_principal = foto_principal
    ad
  end
end
