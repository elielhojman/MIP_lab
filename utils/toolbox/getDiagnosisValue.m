function [ val ] = getDiagnosisValue( name, diagnosis )
side = name(end);
accN = name(1:end-1);
nameNew = [side, accN];
val = getfield(diagnosis,nameNew);

end

