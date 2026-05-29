
import { deployScript } from "../rocketh/deploy.js";
import * as artifacts from "../generated/artifacts/index.js";

export default deployScript(
  async env => {

    const { deployer } =
      env.namedAccounts;

    console.log(
      "🚀 Deploying MiniAave with:",
      deployer
    );

    /**
     * ---------------------------------------------------
     * Deploy MiniAave
     * ---------------------------------------------------
     */
    const miniAave =
      await env.deploy("MiniAave", {
        account: deployer,
        artifact: artifacts.MiniAave,
        args: [],
      });

    console.log(
      "✅ MiniAave deployed:",
      miniAave.address
    );
  },
  {
    tags: ["MiniAave"],
  },
);

