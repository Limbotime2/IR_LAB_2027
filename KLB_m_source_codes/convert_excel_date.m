function dt = convert_excel_date(x)
    if isnumeric(x) && ~isnan(x)
        dt = datetime(x, 'ConvertFrom', 'excel');
    elseif ischar(x) || isstring(x)
        dt = datetime(x);  % Uses default parsing
    elseif isdatetime(x)
        dt = x;
    else
        dt = NaT;  % Handle unexpected or missing cases safely
    end
end