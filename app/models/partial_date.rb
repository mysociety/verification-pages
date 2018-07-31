# frozen_string_literal: true

def fuzzy_partial_date_less_than(a, b)
  if a.length >= 7 && b.length >= 7
    # At full precisioin, we've been saying that a has to be more than
    # a month before b before we say it's earlier. If the dates are at
    # month precision, Date.parse interprets them as the start of the
    # month. This is probably OK for the moment.
    Date.iso8601(a) < (Date.iso8601(b) - 31.days)
  else
    # Otherwise at least one of them is only at year precision. We
    # can't do much better in those situations than truncating to the
    # year part and comparing them with a strict <:
    a[0...4] < b[0...4]
  end
end
