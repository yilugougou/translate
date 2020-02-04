# -*- encoding : utf-8 -*-
class TranslationsController < ApplicationController
  before_action :set_translation, only: [:show, :edit, :update, :destroy]

  # GET /translations
  # GET /translations.json
  def index
    @translations = Translation.all
    require 'translation_tool'
    @TKK = TranslationTool.new.get_tkk
    @results = []
  end

  def get_translate
    require "execjs"
    a = 439118
    b = "+-3^+b+-f"
    d = 0
    while(d < b.length - 2) do
      b = b.to_s
      c = b[d + 2]
      p "function b a value --- 1-*" + c.to_s
      # c = 'a' <= c ? c[0].ord  - 87 : c.to_i
      if 'a' <= c
        c = c[0].ord  - 87
      else
        c = c.to_i
      end
      p "function b a value --- 2-*" + c.to_s

      # c = '+' == b[d + 1] ? a >> c : a << c
      if '+' == b[d + 1]
        # c = a >> c
        c = ExecJS.eval("#{a} >> #{c}")

      else
        # c = a << c
        c = ExecJS.eval("#{a} << #{c}")
      end

      p "function b b value*" + b.to_s
      p "function b b.charAt(d + 1)*"+ b[d + 1].to_s
      p "function b d value"+ d.to_s
      p "function b '+' == b.charAt(d + 1)*#{"+" == b[d + 1]}"
      p "function b a value --- 3-*"+ c.to_s
      if '+' == b[d]
        a = a.to_i + c.to_i
      else
        a = a ^ c
      end
      # a = '+' == b[d] ? a.to_i + c.to_i & 4294967295 : a ^ c
      p "function b a value --- 4-*" + a.to_s
      d += 3
    end
    require 'translation_tool'
    now_time = Time.now()
    # (0..3600).each do |i|
    @results = TranslationTool.new.start_google(params[:q], params[:tk], params[:tl])
    # end

    @TKK = TranslationTool.new.get_tkk
    render :index
  end

  # GET /translations/1
  # GET /translations/1.json
  def show
  end

  # GET /translations/new
  def new
    @translation = Translation.new
  end

  # GET /translations/1/edit
  def edit
  end

  # POST /translations
  # POST /translations.json
  def create
    @translation = Translation.new(translation_params)

    require 'translation_tool'
    @result = ""
    query = translation_params[:input_text]
    begin
      if query.present?
        @result = TranslationTool.new.start(query)
      end
    rescue Exception => e
      Rails.logger.error e
      Rails.logger.error e.backtrace.join("\n")
    end


    respond_to do |format|
      format.html { render :edit }
    end
  end

  # PATCH/PUT /translations/1
  # PATCH/PUT /translations/1.json
  def update
    respond_to do |format|
      if @translation.update(translation_params)
        format.html { redirect_to @translation, notice: 'Translation was successfully updated.' }
        format.json { render :show, status: :ok, location: @translation }
      else
        format.html { render :edit }
        format.json { render json: @translation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /translations/1
  # DELETE /translations/1.json
  def destroy
    @translation.destroy
    respond_to do |format|
      format.html { redirect_to translations_url, notice: 'Translation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_translation
      @translation = Translation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def translation_params
      params.require(:translation).permit(:input_text)
    end
end
