module Agio
  class Revenue
    def initialize(payments_repo, compulsory_sales_repo, free_sales_repo, start_date: nil, end_date: nil)
      filter = {start_date: start_date, end_date: end_date}
      @payments = filtered_collection(payments_repo, filter)
      @compulsory_sales = filtered_collection(compulsory_sales_repo, filter)
      @free_sales = filtered_collection(free_sales_repo, filter)
    end

    def free_sales
      p_stack = @payments.reverse
      s_stack = @free_sales.reverse

      return 0 if p_stack.empty? || s_stack.empty?

      curr_payment, curr_sale = p_stack.pop, s_stack.pop
      sale_revenue(p_stack, s_stack, curr_payment, curr_sale, curr_payment.free_amount, curr_sale.amount, :free)
    end

    def compulsory_sales
      p_stack = @payments.reverse
      s_stack = @compulsory_sales.reverse

      return 0 if p_stack.empty? || s_stack.empty?

      curr_payment, curr_sale = p_stack.pop, s_stack.pop
      sale_revenue(p_stack, s_stack, curr_payment, curr_sale, curr_payment.compulsory_amount, curr_sale.amount, :compulsory)
    end

    def sales
      free_sales + compulsory_sales
    end

    private

    def filtered_collection(repo, start_date: nil, end_date: nil)
      repo.collection.select do |item|
        (start_date.nil? || item.date >= start_date) &&
          (end_date.nil? || item.date <= end_date)
      end
    end

    def sale_revenue(p_stack, s_stack, curr_payment, curr_sale, p_amount, s_amount, sale_type)
      amount = [p_amount, s_amount].min
      earn = (amount * curr_sale.rate).round(2) - (amount * curr_payment.rate).round(2)
      earn = (earn < 0 ? 0 : earn)

      earn +
        if amount == p_amount && amount == s_amount
          payment, sale = p_stack.pop, s_stack.pop
          if payment && sale
            sale_revenue(p_stack, s_stack, payment, sale, payment.public_send("#{sale_type}_amount"), sale.amount, sale_type)
          else
            0
          end
        elsif amount == p_amount
          payment = p_stack.pop
          if payment
            sale_revenue(p_stack, s_stack, payment, curr_sale, payment.public_send("#{sale_type}_amount"), s_amount - amount, sale_type)
          else
            0
          end
        else
          sale = s_stack.pop
          if sale
            sale_revenue(p_stack, s_stack, curr_payment, sale, p_amount - amount, sale.amount, sale_type)
          else
            0
          end
        end
    end
  end
end
