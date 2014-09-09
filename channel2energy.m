function energy = channel2energy(chan, ecal)
energy = ecal(1) + ecal(2)*chan;
if length(ecal)>2
    for k=3:length(ecal)
        energy = energy + ecal(k)*chan.^(k-1);
    end
end