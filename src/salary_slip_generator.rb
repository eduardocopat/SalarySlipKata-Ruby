require 'require_all'
require_all 'src'

class SalarySlipGenerator
  MONTHS_IN_A_YEAR = 12.0
  def generate_for(employee)

    slip = SalarySlip.new
    slip.employee_id = employee.id
    slip.employee_name = employee.name
    slip.gross_salary = (employee.annual_salary / MONTHS_IN_A_YEAR).round(2)
    return slip
  end
end