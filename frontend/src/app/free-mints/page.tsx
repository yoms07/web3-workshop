"use client";

import { useState } from "react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
  CardFooter,
} from "@/components/ui/card";

/**
 * WORKSHOP: FreeMint Token Integration
 *
 * Your task is to integrate this UI with the blockchain using wagmi and viem.
 *
 * Steps to complete:
 * 1. Import necessary hooks from wagmi (useAccount, useConnect, useDisconnect, useReadContract, useWriteContract)
 * 2. Import utilities from viem (isAddress, parseUnits, formatUnits)
 * 3. Define the contract ABI and address
 * 4. Read token metadata (decimals, symbol)
 * 5. Query token balance (use refetch() to refresh on button click)
 * 6. Implement wallet connection/disconnection
 * 7. Implement "Use my address" feature
 * 8. Implement balance query handler
 * 9. Implement mint functionality
 *
 * Hint: Check the solution file at free-mints-solution/page.tsx for reference
 */

export default function FreeMintsPage() {
  // TODO: Step 1 - Add wallet connection hooks
  // Use: useAccount, useConnect, useDisconnect from wagmi
  // Example: const { address, isConnected } = useAccount();

  // TODO: Step 2 - Add contract write hook
  // Use: useWriteContract from wagmi
  // Example: const { writeContract, isPending: isMinting } = useWriteContract();

  // Form state - you can keep these as they are
  const [balanceAddress, setBalanceAddress] = useState("");
  const [mintAmount, setMintAmount] = useState("");

  // TODO: Step 3 - Define contract constants
  // Add CONTRACT_ADDRESS and CONTRACT_ABI here
  // The ABI should include: balanceOf, decimals, symbol, mint functions
  // Contract address: You'll get this after deploying the contract

  // TODO: Step 4 - Read token metadata (decimals, symbol)
  // Use: useReadContract from wagmi
  // Read decimals and symbol from the contract
  // Example:
  // const { data: decimals } = useReadContract({
  //   address: CONTRACT_ADDRESS,
  //   abi: CONTRACT_ABI,
  //   functionName: "decimals",
  // });

  // TODO: Step 5 - Query balance
  // Use: useReadContract with balanceOf function
  // Enable the query when address is valid (use isAddress from viem to validate)
  // The query will have a refetch() method you can call to refresh the balance
  // Example:
  // const balanceQuery = useReadContract({
  //   address: CONTRACT_ADDRESS,
  //   abi: CONTRACT_ABI,
  //   functionName: "balanceOf",
  //   args: isValidAddress ? [balanceAddress] : undefined,
  //   query: { enabled: isValidAddress },
  // });

  // TODO: Step 6 - Format balance result
  // Use formatUnits from viem to format the balance
  // Combine with token symbol for display
  // Use useMemo to derive the formatted result from balanceQuery.data

  // Placeholder values for UI (remove these once you implement the real logic)
  const isConnected = false; // TODO: Replace with actual isConnected from useAccount
  const address: string | undefined = undefined; // TODO: Replace with actual address from useAccount
  const isConnecting = false; // TODO: Replace with actual isConnecting from useConnect
  const isMinting = false; // TODO: Replace with actual isMinting from useWriteContract
  const balanceResult = ""; // TODO: Replace with formatted balance from query
  const isLoadingBalance = false; // TODO: Replace with actual loading state from balance query

  // TODO: Step 7 - Implement wallet connection handler
  // Use connect hook with injected() connector from wagmi/connectors
  // Add error handling with toast notifications
  const handleConnectWallet = async () => {
    // TODO: Implement wallet connection
    toast.info("Implement wallet connection");
  };

  // TODO: Step 8 - Implement disconnect handler
  const handleDisconnect = () => {
    // TODO: Implement wallet disconnection
    toast.info("Implement wallet disconnection");
  };

  // TODO: Step 9 - Implement "Use my address" handler (optional but helpful)
  // Fill the balanceAddress input with the connected wallet address
  // Only show this option when wallet is connected
  const handleUseMyAddress = () => {
    // TODO: Set balanceAddress to the connected address
    toast.info("Implement use my address");
  };

  // TODO: Step 10 - Implement balance query handler
  // Validate address using isAddress from viem
  // Call balanceQuery.refetch() to refresh the balance
  // Add error handling for invalid addresses
  const handleCheckBalance = () => {
    // TODO: Implement balance checking
    if (!balanceAddress.trim()) {
      toast.error("Please enter an address to query");
      return;
    }
    // TODO: Validate address and call balanceQuery.refetch()
    toast.info("Implement balance query");
  };

  // TODO: Step 11 - Implement mint handler
  // Check if wallet is connected
  // Validate mint amount
  // Use parseUnits from viem to convert amount to wei
  // Call writeContract with mint function
  // Add error handling and success notifications
  const handleMint = async () => {
    // TODO: Implement minting
    if (!isConnected) {
      toast.error("Please connect your wallet first");
      return;
    }
    if (!mintAmount.trim()) {
      toast.error("Please enter an amount to mint");
      return;
    }
    // TODO: Parse amount and call writeContract
    toast.info("Implement minting");
  };

  return (
    <div className="min-h-[calc(100vh-4rem)] w-full px-6 py-10 max-w-4xl mx-auto">
      {/* Header Section */}
      <header className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl font-semibold text-white">FreeMint Token</h1>
          <p className="text-sm text-neutral-300">
            Query balances and mint tokens to your connected wallet
          </p>
        </div>

        {isConnected ? (
          <div className="flex items-center gap-3">
            <span className="text-xs text-neutral-300 hidden sm:inline">
              {address || "0x..."}
            </span>
            <Button variant="secondary" onClick={handleDisconnect}>
              Disconnect
            </Button>
          </div>
        ) : (
          <Button onClick={handleConnectWallet} disabled={isConnecting}>
            {isConnecting ? "Connecting..." : "Connect Wallet"}
          </Button>
        )}
      </header>

      {/* Main Content Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Balance Query Card */}
        <Card>
          <CardHeader>
            <CardTitle>Query Balance</CardTitle>
            <CardDescription>
              Enter an address to check its token balance
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="flex items-center justify-between">
              <label
                className="block text-sm font-medium"
                htmlFor="balance-address"
              >
                Address
              </label>
              {isConnected && address && (
                <Button
                  type="button"
                  variant="ghost"
                  size="sm"
                  onClick={handleUseMyAddress}
                  className="text-xs h-7"
                >
                  Use my address
                </Button>
              )}
            </div>
            <Input
              id="balance-address"
              type="text"
              placeholder="0x..."
              value={balanceAddress}
              onChange={(e) => setBalanceAddress(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === "Enter") {
                  handleCheckBalance();
                }
              }}
            />
            {balanceResult && (
              <div className="p-3 bg-neutral-800 rounded-md">
                <p className="text-sm font-medium text-neutral-300">
                  Balance: <span className="text-white">{balanceResult}</span>
                </p>
              </div>
            )}
            {isLoadingBalance && (
              <p className="text-sm text-neutral-400">Loading balance...</p>
            )}
          </CardContent>
          <CardFooter className="flex items-center justify-between">
            <Button onClick={handleCheckBalance} disabled={isLoadingBalance}>
              Check Balance
            </Button>
          </CardFooter>
        </Card>

        {/* Mint Card */}
        <Card>
          <CardHeader>
            <CardTitle>Mint Tokens</CardTitle>
            <CardDescription>
              Mint tokens to your connected wallet address
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            <div>
              <label
                className="block text-sm font-medium mb-2"
                htmlFor="mint-amount"
              >
                Amount
              </label>
              <Input
                id="mint-amount"
                type="number"
                min="0"
                step="any"
                placeholder="e.g. 1000"
                value={mintAmount}
                onChange={(e) => setMintAmount(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === "Enter" && isConnected) {
                    handleMint();
                  }
                }}
              />
              {isConnected && address && (
                <p className="text-xs text-neutral-400 mt-2">
                  Will mint to: {address}
                </p>
              )}
            </div>
          </CardContent>
          <CardFooter className="flex items-center justify-between">
            <p className="text-xs text-neutral-400">
              Tokens mint to your wallet
            </p>
            <Button onClick={handleMint} disabled={!isConnected || isMinting}>
              {isMinting ? "Minting..." : "Mint"}
            </Button>
          </CardFooter>
        </Card>
      </div>
    </div>
  );
}
