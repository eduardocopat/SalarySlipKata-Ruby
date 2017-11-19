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
  attr_accessor :amount

  def initialize(amount)
    @amount = amount
  end

  def deduct_taxes
    tax = Tax.new

    deductions = DeductionFactory.make_tax_deductions(@amount)

    #Refactor to collect?
    deductions.each {|deduction|
      deduction.calculate()
      tax.payable = tax.payable + deduction.value
    }
    
    if tax.payable > 0
      tax.income = ((@amount - 11000)/12.00).round(2)
      tax.free_allowance = (to_monthly - tax.income).round(2)
    end

    return tax
  end

  def to_monthly
    (@amount / MONTHS_IN_A_YEAR).round(2)
  end

  def deduct_national_insurance

    national_insurance_deduction = 0
    deductions = DeductionFactory.make_national_insurance_deductions(@amount)

    #Refactor to collect?
    deductions.each {|deduction|
      deduction.calculate()
      national_insurance_deduction = national_insurance_deduction + deduction.value
    }

    national_insurance_deduction.round(2)
  end
end

class DeductionFactory
  def self.make_tax_deductions(salary_amount)
    remaining_taxable_amount = salary_amount
    deductions = []

    if salary_amount > 43000.00
      taxable_amount = remaining_taxable_amount - 43000
      deductions.push(Deduction.new(taxable_amount, 0.40))
      remaining_taxable_amount = remaining_taxable_amount - taxable_amount
    end

    if remaining_taxable_amount > 11000.00
      deductions.push( Deduction.new(remaining_taxable_amount - 11000.00, 0.20))
    end
    return deductions
  end
  def self.make_national_insurance_deductions(salary_amount)
    remaining_taxable_amount = salary_amount
    deductions = []

    if salary_amount > 43000.00
      taxable_amount = remaining_taxable_amount - 43000
      deductions.push(Deduction.new(taxable_amount, 0.02))
      remaining_taxable_amount = remaining_taxable_amount - taxable_amount
    end

    if remaining_taxable_amount > 8060.00
      deductions.push( Deduction.new(remaining_taxable_amount - 8060.00, 0.12))
    end
    return deductions
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
  def initialize(amount, rate)
    @amount = amount
    @rate = rate
  end

  def calculate()
    monthly_amount = (@amount / MONTHS_IN_A_YEAR).round(2)
    @value = (monthly_amount * @rate).round(2)
  end
end


