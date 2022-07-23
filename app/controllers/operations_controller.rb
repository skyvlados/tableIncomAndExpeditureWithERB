# frozen_string_literal: true

class OperationsController < ApplicationController
  def index
    service = OperationQuery.new(params)
    scope = service.call
    @pagy, @operations = pagy(scope.order(date: :desc), items: params[:page_size])

    @totals_operations = scope
                         .order(direction: :asc)
                         .group(:currency, :direction)
                         .pluck('sum(amount)', 'currency', 'direction')
    @params = index_params
    respond_to do |format|
      format.xlsx
      format.html
    end
  end

  def show
    @operation = Operation.find(params[:id])
  end

  def new
    @operation = Operation.new
  end

  def create
    @operation = Operation.new(operation_params)
    if @operation.save
      flash[:notice] = "Operation '#{@operation.id}' successfully saved!"
      redirect_to action: 'index'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @operation = Operation.find(params[:id])
  end

  def update
    @operation = Operation.find(params[:id])
    if @operation.update(operation_params)
      flash[:notice] = 'Operation successfully updated!'
      redirect_to action: 'index'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    operation = Operation.find(params[:id])
    operation.destroy
    flash[:notice] = "Operation '#{operation.id}' successfully deleted!"
    redirect_to operations_path, status: 303
  end

  private

  def operation_params
    params.require(:operation).permit(:direction, :category_id, :date, :amount, :currency)
  end

  def index_params
    params.permit(:currency, :direction, :category, :date_start, :date_finish)
  end
end
