namespace Sen.Script.Executor.Methods.PopCap.CryptData.Encrypt {
    /**
     * Argument for the current method
     */

    export interface Argument extends Sen.Script.Executor.Base {
        source: string;
        destination?: string;
        key?: string;
    }

    /**
     * Argument for batch method
     */

    export interface BatchArgument extends Sen.Script.Executor.Base {
        directory: string;
        key?: string;
    }

    /**
     * Async support
     */

    export interface AsyncArgument extends Sen.Script.Executor.Base {
        parameter: Array<[string, string]>;
        key?: string;
    }

    /**
     * Configuration file if needed
     */

    export interface Configuration extends Sen.Script.Executor.Configuration {
        key: "?" | string;
    }

    /**
     * ----------------------------------------------
     * JavaScript forward method, this method need
     * to be evaluated during script loading time
     * ----------------------------------------------
     */

    export function forward(): void {
        Sen.Script.Executor.push_as_module<
            Sen.Script.Executor.Methods.PopCap.CryptData.Encrypt.Argument,
            Sen.Script.Executor.Methods.PopCap.CryptData.Encrypt.BatchArgument,
            Sen.Script.Executor.Methods.PopCap.CryptData.Encrypt.AsyncArgument,
            Sen.Script.Executor.Methods.PopCap.CryptData.Encrypt.Configuration
        >({
            id: "popcap.crypt_data.encrypt",
            configuration_file: Sen.Script.Home.query("~/Executor/Configuration/popcap.crypt_data.encrypt.json"),
            direct_forward(argument: Sen.Script.Executor.Methods.PopCap.CryptData.Encrypt.Argument): void {
                Sen.Script.Console.obtained(argument.source);
                defined_or_default<Sen.Script.Executor.Methods.PopCap.CryptData.Encrypt.Argument, string>(argument, "destination", `${Sen.Kernel.Path.except_extension(argument.source)}.bin`);
                Sen.Script.Console.output(argument.destination!);
                Sen.Script.Executor.load_string(argument, "key", this.configuration, Sen.Kernel.Language.get("popcap.crypt_data.encrypt.key"));
                Sen.Script.Executor.clock.start_safe();
                Sen.Kernel.Support.PopCap.CryptData.encrypt_fs(argument.source, argument.destination!, argument.key!);
                Sen.Script.Executor.clock.stop_safe();
                return;
            },
            batch_forward(argument: Sen.Script.Executor.Methods.PopCap.CryptData.Encrypt.BatchArgument): void {
                return basic_batch(this, argument, false);
            },
            async_forward(argument: Sen.Script.Executor.Methods.PopCap.CryptData.Encrypt.AsyncArgument): void {
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
                    // Sen.Kernel.Support.PopCap.CryptData.encode_fs_as_multiple_threads(...current_thread);
                }
                Sen.Script.Executor.clock.stop_safe();
                Sen.Script.Console.finished(Sen.Script.format(Sen.Kernel.Language.get("batch.process.count"), argument.parameter.length));
                return;
            },
            is_enabled: true,
            configuration: undefined!,
            filter: ["file", /(.+)\.bin$/i],
        });
        return;
    }
}

Sen.Script.Executor.Methods.PopCap.CryptData.Encrypt.forward();
