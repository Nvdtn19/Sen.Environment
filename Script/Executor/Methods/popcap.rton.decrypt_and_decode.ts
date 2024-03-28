namespace Sen.Script.Executor.Methods.PopCap.RTON.DecryptAndDecode {
    /**
     * Argument for the current method
     */

    export interface Argument extends Sen.Script.Executor.Base {
        source: string;
        destination?: string;
        key?: string;
        iv?: string;
        use_64_bit_variant?: boolean;
    }

    /**
     * Argument for batch method
     */

    export interface BatchArgument extends Sen.Script.Executor.Base {
        directory: string;
        key?: string;
        iv?: string;
        use_64_bit_variant?: boolean;
    }

    /**
     * Async support
     */

    export interface AsyncArgument extends Sen.Script.Executor.Base {
        parameter: Array<[string, string]>;
        key?: string;
        iv?: string;
        use_64_bit_variant?: boolean;
    }

    /**
     * Configuration file if needed
     */

    export interface Configuration extends Sen.Script.Executor.Configuration {
        key?: string;
        iv?: string;
        use_64_bit_variant?: boolean;
    }

    /**
     * ----------------------------------------------
     * JavaScript forward method, this method need
     * to be evaluated during script loading time
     * ----------------------------------------------
     */

    export function forward(): void {
        Sen.Script.Executor.push_as_module<
            Sen.Script.Executor.Methods.PopCap.RTON.DecryptAndDecode.Argument,
            Sen.Script.Executor.Methods.PopCap.RTON.DecryptAndDecode.BatchArgument,
            Sen.Script.Executor.Methods.PopCap.RTON.DecryptAndDecode.AsyncArgument,
            Sen.Script.Executor.Methods.PopCap.RTON.DecryptAndDecode.Configuration
        >({
            id: "popcap.rton.decrypt_and_decode",
            configuration_file: Sen.Script.Home.query("~/Executor/Configuration/popcap.rton.decrypt_and_decode.json"),
            direct_forward(argument: Sen.Script.Executor.Methods.PopCap.RTON.DecryptAndDecode.Argument): void {
                Sen.Script.Console.obtained(argument.source);
                defined_or_default<Argument, string>(argument, "destination", `${Kernel.Path.except_extension(argument.source)}.json`);
                Sen.Script.Console.output(argument.destination!);
                Sen.Script.Executor.load_string(argument, "key", this.configuration, Sen.Kernel.Language.get("popcap.rton.decrypt.key"));
                Sen.Script.Executor.load_string(argument, "iv", this.configuration, Sen.Kernel.Language.get("popcap.rton.decrypt.iv"));
                Sen.Script.Executor.clock.start_safe();
                Sen.Kernel.Support.PopCap.RTON.decrypt_and_decode_fs(argument.source, argument.destination!, argument.key!, argument.iv!);
                Sen.Script.Executor.clock.stop_safe();
                return;
            },
            batch_forward(argument: Sen.Script.Executor.Methods.PopCap.RTON.DecryptAndDecode.BatchArgument): void {
                return basic_batch(this, argument, false);
            },
            async_forward(argument: Sen.Script.Executor.Methods.PopCap.RTON.DecryptAndDecode.AsyncArgument): void {
                Sen.Script.Executor.clock.start_safe();
                for (let i = 0n; i < BigInt(argument.parameter.length); i += Setting.setting.thread_limit_count) {
                    const current_thread: Array<[string, string]> = [
                        ...argument.parameter.slice(
                            Number(i),
                            i + Setting.setting.thread_limit_count <= BigInt(argument.parameter.length) ? Number(i + Setting.setting.thread_limit_count) : argument.parameter.length,
                        ),
                    ];
                    current_thread.forEach((e: [string, string]) => {
                        Sen.Script.Console.obtained(e[0]);
                        Sen.Script.Console.output(e[1]);
                    });
                }
                Sen.Script.Executor.clock.stop_safe();
                Sen.Script.Console.finished(Sen.Script.format(Sen.Kernel.Language.get("batch.process.count"), argument.parameter.length));
                return;
            },
            is_enabled: true,
            configuration: undefined!,
            filter: ["file", /(.+)(\.rton|pp\.dat)$/i],
        });
        return;
    }
}

Sen.Script.Executor.Methods.PopCap.RTON.DecryptAndDecode.forward();
