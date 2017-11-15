require 'require_all'
require_all 'src'

class SalarySlipGenerator

  def generate_for(employee)

    slip = SalarySlip.new
    slip.employee_id = employee.id
    slip.employee_name = employee.name
    annual_salary = AnnualSalary.new(employee.annual_salary)
    monthly_salary = annual_salary.to_monthly
    slip.gross_salary = monthly_salary.value
    slip.national_insurance_contributions = monthly_salary.calculate_national_insurance
    return slip
  end
end

class Salary
  MONTHS_IN_A_YEAR = 12.0
  attr_accessor :value
  def initialize(value)
    @value = value
  end
end

class AnnualSalary < Salary
  def to_monthly
    MonthlySalary.new((@value / MONTHS_IN_A_YEAR).round(2))
  end
end

class MonthlySalary < Salary
  def calculate_national_insurance
    (@value * 0.12).round(2)
  end
end