class UsuariosController < ApplicationController
  before_action :entroAlSistema?, :except => [:inicia_sesion, :intento_sesion, :new, :create, :filtros, :limpiar,
                                              :cambia_locale]
  before_action :set_usuario, only: [:show, :edit, :update, :destroy]
  before_action :only => [:index, :edit, :update, :destroy] do |c|
    c.tienePermiso? @usuario.id
  end

  layout :false, :only => [:filtros, :limpiar, :cambia_locale]

  # GET /usuarios
  # GET /usuarios.json
  def index
    @usuarios = Usuario.all
  end

  # GET /usuarios/1
  # GET /usuarios/1.json
  def show
  end

  # GET /usuarios/new
  def new
    @usuario = Usuario.new
  end

  # GET /usuarios/1/edit
  def edit
  end

  # POST /usuarios
  # POST /usuarios.json
  def create
    @usuario = Usuario.new(usuario_params)

    respond_to do |format|
      if @usuario.save
        format.html { redirect_to inicia_sesion_usuarios_url, notice: 'Tu cuenta fue creada exitosamente.' }
        format.json { render action: 'show', status: :created, location: @usuario }
      else
        format.html { render action: 'new' }
        format.json { render json: @usuario.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /usuarios/1
  # PATCH/PUT /usuarios/1.json
  def update
    respond_to do |format|
      if @usuario.update(usuario_params)
        format.html { redirect_to @usuario, notice: 'Tu cuenta ha sido actualizada exitosamente.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @usuario.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /usuarios/1
  # DELETE /usuarios/1.json
  def destroy
    @usuario.destroy
    respond_to do |format|
      format.html { redirect_to usuarios_url }
      format.json { head :no_content }
    end
  end

  def inicia_sesion
  end

  def intento_sesion
    usuario=Usuario.autentica(params[:login], params[:contrasenia])
    if usuario.present?
      ponSesion(usuario)
      respond_to do |format|
        format.html { redirect_to root_url, :notice => "Bienvenido #{usuario.nombre} #{usuario.apellido}" }
      end
    else
      respond_to do |format|
        format.html { redirect_to '/usuarios/inicia_sesion', :notice => 'El usuario/correo o contraseña son incorrectos.' }
      end
    end
  end

  def cierra_sesion
    cierraSesion
    respond_to do |format|
      format.html { redirect_to '/usuarios/inicia_sesion', :notice => 'La sesión se cerró correctamente.' }
    end
  end

  def filtros
    filtro=Filtro.sesion_o_usuario(request.session_options[:id], session[:usuario].present? ? session[:usuario] : nil, params[:html], to_boolean(params[:lectura]))
    if filtro[:existia].present?
      @html=filtro[:html] if filtro[:existia]
    end
  end

  def limpiar
    @filtro=Filtro.consulta(request.session_options[:id], session[:usuario].present? ? session[:usuario] : nil)
  end

  def cambia_locale       #decide en donde gaurdar el locale
    return if params[:locale].blank? || !I18n.available_locales.map{ |loc| loc.to_s }.include?(params[:locale])
    if session[:usuario].present?
      begin
        usuario = Usuario.find(session[:usuario])
        usuario.locale = params[:locale]
        @res = true if usuario.save
      rescue
      end
    else
      filtro = Filtro.where(:sesion => request.session_options[:id])
      if filtro
        filtro.first.locale = params[:locale]
        filtro.first.save if filtro.first.locale_changed?
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_usuario
    @usuario = Usuario.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def usuario_params
    params.require(:usuario).permit(:usuario, :correo, :nombre, :apellido, :institucion,
                                    :grado_academico, :contrasenia, :confirma_contrasenia)
  end
end
