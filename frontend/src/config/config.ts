import { createConfig, http } from "wagmi";
import { hoodi } from "wagmi/chains";

// Only support hoodi testnet
export const config = createConfig({
  chains: [hoodi],
  transports: {
    [hoodi.id]: http(),
  },
});
