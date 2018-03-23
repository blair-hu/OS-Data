function [feats] = getTDfeats(DataSet)
frameLen = size(DataSet,1);
DEADZONE = 0.025;

Ntotal = size(DataSet,1);
Nsig = size(DataSet,2);
DataSet = DataSet - ones(Ntotal,1)*mean(DataSet);

feats = zeros(4,Nsig);

for SigNum = 1:Nsig
    clear mav turns zero_count len;
    zero_count = 0;
    len = 0;
    mav = 0;
    turns = 0;

    index = 1;
    range = index:index+frameLen-1;
    mav = mean(abs(DataSet(range,SigNum)));
    mrv = mean(abs(DataSet(range,SigNum)-mean(DataSet(range,SigNum))));
    flag1 = 1;
    flag2 = 1;
    for i = 1:frameLen-2;
        idx = index + i;
        fst = DataSet(idx-1,SigNum);
        mid = DataSet(idx,SigNum);
        lst = DataSet(idx+1,SigNum);

        % Compute Zero Crossings
        if ((mid>=0 & fst>=0) | (mid<=0 & fst<=0))
            flag1 = flag2;
        elseif ((mid<DEADZONE) & (mid>-DEADZONE) & (fst<DEADZONE) & (fst>-DEADZONE))
            flag1 = flag2;
        else
            flag1 = (-1)*flag2;
        end
        if (flag1~=flag2);
            zero_count = zero_count + 1;
            flag1 = flag2;
        end
        % Compute Turns (Slope Changes
        if((mid>fst & mid>lst) | (mid<fst & mid<lst))
            % turns threshold of 15mV (i.e. 3uV noise)
            if (abs(mid-fst)>0.015) | (abs(mid-lst)>0.015)
                turns=turns+1;
            end
        end
        % Compute Waveform Length
        len = len + abs(fst-mid);
    end
    feats(:,SigNum) = [mav len turns zero_count]';
end