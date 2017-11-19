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

    high_earner_tax_increase = 0


    #constants?
    if @amount > 11000
      if @amount > 100000
        high_earner_tax_increase = (((@amount - 100000.00) / 2.00))
        puts "high earned increase #{high_earner_tax_increase}"
      end

      tax.income = ((@amount - 11000 + high_earner_tax_increase) / 12.00)
      if tax.income > to_monthly
        tax.income = to_monthly
      end

      tax.free_allowance = (to_monthly - tax.income)

    end

    deductions = DeductionFactory.make_tax_deductions(@amount + high_earner_tax_increase)

    deductions.each {|deduction|
      deduction.calculate()
      tax.payable = tax.payable + deduction.value
    }

    tax.free_allowance = tax.free_allowance.round(2)
    tax.income = tax.income.round(2)
    tax.payable = (tax.payable / MONTHS_IN_A_YEAR).round(2)

    return tax
  end

  def to_monthly
    (@amount / MONTHS_IN_A_YEAR).round(2)
  end

  def deduct_national_insurance
    national_insurance_deduction = 0
    deductions = DeductionFactory.make_national_insurance_deductions(@amount)

    deductions.each {|deduction|
      deduction.calculate()
      national_insurance_deduction = national_insurance_deduction + deduction.value
    }

    (national_insurance_deduction / MONTHS_IN_A_YEAR).round(2)
  end
end

class DeductionFactory
  def self.make_tax_deductions(salary_amount)
    remaining_taxable_amount = salary_amount
    deductions = []

    if remaining_taxable_amount > 150000.00
      taxable_amount = remaining_taxable_amount - 107000
      deductions.push(Deduction.new(taxable_amount, 0.45))
      remaining_taxable_amount = remaining_taxable_amount - taxable_amount
    end

    if remaining_taxable_amount >= 43000.00
      taxable_amount =  remaining_taxable_amount - 43000
      deductions.push(Deduction.new(taxable_amount, 0.40))
      remaining_taxable_amount = remaining_taxable_amount - taxable_amount
    end

    if remaining_taxable_amount >= 11000.00
      deductions.push(Deduction.new(remaining_taxable_amount-11000, 0.20))
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
      deductions.push(Deduction.new(remaining_taxable_amount - 8060.00, 0.12))
    end
    return deductions
  end
end

class Tax
  attr_accessor :free_allowance
  attr_accessor :income
  attr_accessor :payable

  def initialize
    @free_allowance = @income = @payable = 0.00
  end
end

class Deduction
  attr_accessor :value

  def initialize(amount, rate)
    @amount = amount
    @rate = rate
  end

  def calculate
    @value = (@amount * @rate).round(2)
  end
end


