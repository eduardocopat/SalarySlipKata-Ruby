require 'require_all'
require_all 'src'

class SalarySlipGenerator

  def generate_for(employee)

    slip = SalarySlip.new
    slip.employee_id = employee.id
    slip.employee_name = employee.name

    salary = Salary.new(employee.annual_salary)

    slip.gross_salary = salary.to_monthly
    slip.national_insurance_contributions = salary.calculate_national_insurance
    return slip
  end
end

class Salary
  attr_accessor :value

  MONTHS_IN_A_YEAR = 12.0
  #TODO convert to an object?
  NATIONAL_INSURANCE_THRESHOLD = 8060
  NATIONAL_INSURANCE_CONTRIBUTION = 0.12

  def initialize(value)
    @value = value
  end

  def to_monthly
    (@value / MONTHS_IN_A_YEAR).round(2)
  end

  def calculate_national_insurance
    if @value > NATIONAL_INSURANCE_THRESHOLD
      (to_monthly * NATIONAL_INSURANCE_CONTRIBUTION).round(2)
    else
      0.00
    end
  end
end
