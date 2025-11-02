import { createConfig, http } from "wagmi";
import { hoodi, mainnet, sepolia } from "wagmi/chains";

export const config = createConfig({
  chains: [mainnet, sepolia, hoodi],
  transports: {
    [mainnet.id]: http(),
    [sepolia.id]: http(),
    [hoodi.id]: http(),
  },
});
