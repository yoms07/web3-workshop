"use client";

import React from "react";
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

export default function FreeMintsPage() {
  const [balanceAddress, setBalanceAddress] = React.useState("");
  const [mintAddress, setMintAddress] = React.useState("");
  const [mintAmount, setMintAmount] = React.useState("");

  // UI-only handlers (no web3 integration yet)
  const handleConnectWallet = () => {
    toast.info("Wallet connection UI only (no web3 yet)");
  };

  const handleCheckBalance = () => {
    if (!balanceAddress) {
      toast.error("Please enter an address to query");
      return;
    }
    toast.success(`Pretending to query balance for ${balanceAddress}`);
  };

  const handleMint = () => {
    if (!mintAddress || !mintAmount) {
      toast.error("Please enter address and amount to mint");
      return;
    }
    toast.success(`Pretending to mint ${mintAmount} tokens to ${mintAddress}`);
  };

  return (
    <div className="min-h-[calc(100vh-4rem)] w-full px-6 py-10 max-w-4xl mx-auto">
      {/* Header */}
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl font-semibold text-white">FreeMint Token</h1>
          <p className="text-sm text-neutral-600">
            UI to explore querying balances and minting tokens.
          </p>
        </div>
        <Button onClick={handleConnectWallet}>Connect Wallet</Button>
      </div>

      {/* Content grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Query Balance */}
        <Card>
          <CardHeader>
            <CardTitle>Query Balance</CardTitle>
            <CardDescription>
              Enter an address to check its balance.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            <label
              className="block text-sm font-medium"
              htmlFor="balance-address"
            >
              Address
            </label>
            <Input
              id="balance-address"
              type="text"
              placeholder="0x..."
              value={balanceAddress}
              onChange={(e) => setBalanceAddress(e.target.value)}
            />
          </CardContent>
          <CardFooter className="flex items-center justify-between">
            <p className="text-xs text-neutral-600">
              This simulates a balance query. Web3 integration will be added
              later.
            </p>
            <Button onClick={handleCheckBalance}>Check Balance</Button>
          </CardFooter>
        </Card>

        {/* Mint */}
        <Card>
          <CardHeader>
            <CardTitle>Mint Tokens</CardTitle>
            <CardDescription>
              Provide recipient and amount to mint.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            <div>
              <label
                className="block text-sm font-medium"
                htmlFor="mint-address"
              >
                Recipient Address
              </label>
              <Input
                id="mint-address"
                type="text"
                placeholder="0x..."
                value={mintAddress}
                onChange={(e) => setMintAddress(e.target.value)}
              />
            </div>
            <div>
              <label
                className="block text-sm font-medium"
                htmlFor="mint-amount"
              >
                Amount
              </label>
              <Input
                id="mint-amount"
                type="number"
                min={0}
                placeholder="e.g. 1000"
                value={mintAmount}
                onChange={(e) => setMintAmount(e.target.value)}
              />
            </div>
          </CardContent>
          <CardFooter className="flex items-center justify-between">
            <p className="text-xs text-neutral-600">
              This simulates a mint action. Web3 integration will be added
              later.
            </p>
            <Button onClick={handleMint}>Mint</Button>
          </CardFooter>
        </Card>
      </div>
    </div>
  );
}
