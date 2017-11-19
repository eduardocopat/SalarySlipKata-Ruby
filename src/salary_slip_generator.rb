require 'require_all'
require_all 'src'

class SalarySlipGenerator

  def generate_for(employee)

    slip = SalarySlip.new
    slip.employee_id = employee.id
    slip.employee_name = employee.name

    salary = Salary.new(employee.annual_salary)

    slip.gross_salary = salary.to_monthly
    slip.national_insurance_contributions = salary.deduct_national_insurance

    tax = salary.deduct_taxes
    slip.tax_free_allowance = tax.free_allowance
    slip.tax_payable = tax.payable
    slip.taxable_income = tax.income
    return slip
  end
end

MONTHS_IN_A_YEAR = 12.0

class Salary
  attr_accessor :value

  def initialize(value)
    @value = value
  end

  def deduct_taxes
    tax = Tax.new

    remaining_taxable_amount = @value

    if @value > 43000.00
      taxable_amount = remaining_taxable_amount - 43000

      deduction = Deduction.new(taxable_amount)

      remaining_taxable_amount = remaining_taxable_amount - taxable_amount
      deduction.calculate(0.40)

      tax.payable = tax.payable + deduction.value
    end

    if @value > 11000.00
      deduction = Deduction.new(remaining_taxable_amount - 11000.00)
      deduction.calculate(0.20)
      tax.payable = tax.payable + deduction.value
    end

    if tax.payable > 0
      tax.income = ((@value - 11000)/12.00).round(2)
      tax.free_allowance = (to_monthly - tax.income).round(2)
    end

    return tax
  end

  def to_monthly
    (@value / MONTHS_IN_A_YEAR).round(2)
  end

  def deduct_national_insurance

    national_insurance_deduction = 0
    remaining_deduction_amount = @value

    if @value > 43000
      amount = remaining_deduction_amount - 43000
      remaining_deduction_amount = remaining_deduction_amount - amount

      deduction = Deduction.new(amount)
      deduction.calculate(0.02)

      national_insurance_deduction = national_insurance_deduction + deduction.value
    end

    if @value > 8060
      amount = remaining_deduction_amount - 8060
      deduction = Deduction.new(amount)
      deduction.calculate(0.12)

      national_insurance_deduction = national_insurance_deduction + deduction.value
    end

    national_insurance_deduction.round(2)
  end
end

class Tax
  attr_accessor :free_allowance
  attr_accessor :income
  attr_accessor :payable

  def initialize
    @free_allowance = @income = @payable = 0
  end
end

class Deduction
  attr_accessor :value
  def initialize(amount)
    @amount = amount
  end

  def calculate(rate)
    monthly_amount = (@amount / MONTHS_IN_A_YEAR).round(2)
    @value = (monthly_amount * rate).round(2)
  end
end


