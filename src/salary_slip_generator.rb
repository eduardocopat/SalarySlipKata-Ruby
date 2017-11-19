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

    tax = salary.apply_taxes
    slip.tax_free_allowance = tax.free_allowance
    slip.tax_payable = tax.payable
    slip.taxable_income = tax.income
    return slip
  end
end

MONTHS_IN_A_YEAR = 12.0

class Salary
  attr_accessor :value

  NATIONAL_INSURANCE_THRESHOLD = 8060
  NATIONAL_INSURANCE_CONTRIBUTION_RATE = 0.12

  def initialize(value)
    @value = value
  end

  def apply_taxes
    if @value > 11000.00
      tax = Tax.new(@value - 11000)
      tax.calculate
      return tax
    else
      tax = NullTax.new(@value)
      return tax
    end
  end

  def to_monthly
    (@value / MONTHS_IN_A_YEAR).round(2)
  end

  def calculate_national_insurance
    if @value > NATIONAL_INSURANCE_THRESHOLD
      exceeding_amount = @value - NATIONAL_INSURANCE_THRESHOLD
      ((exceeding_amount / MONTHS_IN_A_YEAR ) * NATIONAL_INSURANCE_CONTRIBUTION_RATE).round(2)
    else
      0.00
    end
  end
end

class Tax
  attr_accessor :free_allowance
  attr_accessor :income
  attr_accessor :payable
  def initialize(amount)
    @amount = amount
  end

  def calculate
    @income = (@amount / MONTHS_IN_A_YEAR).round(2)
    @payable = (@income * 0.20).round(2)
    @free_allowance = (@amount - @income).round(2)

  end
end

class NullTax < Tax
  def initialize(amount)
    @free_allowance = @income = @payable = 0
  end
end


