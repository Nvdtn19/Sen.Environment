namespace Sen.Script.Executor.Methods.PopCap.Reanim.ToFlash {
    /**
     * Argument for the current method
     */

    export interface Argument extends Sen.Script.Executor.Base {
        source: string;
        destination?: string;
    }

    /**
     * Argument for batch method
     */

    export interface BatchArgument extends Sen.Script.Executor.Base {
        directory: string;
    }

    /**
     * Async support
     */

    export interface AsyncArgument extends Sen.Script.Executor.Base {
        parameter: Array<[string, string]>;
    }

    /**
     * Configuration file if needed
     */

    export interface Configuration extends Sen.Script.Executor.Configuration {}

    /**
     * ----------------------------------------------
     * JavaScript forward method, this method need
     * to be evaluated during script loading time
     * ----------------------------------------------
     */

    export function forward(): void {
        Sen.Script.Executor.push_as_module<
            Sen.Script.Executor.Methods.PopCap.Reanim.ToFlash.Argument,
            Sen.Script.Executor.Methods.PopCap.Reanim.ToFlash.BatchArgument,
            Sen.Script.Executor.Methods.PopCap.Reanim.ToFlash.AsyncArgument,
            Sen.Script.Executor.Methods.PopCap.Reanim.ToFlash.Configuration
        >({
            id: "popcap.reanim.to_flash",
            configuration_file: Home.query("~/Executor/Configuration/popcap.reanim.to_flash.json"),
            direct_forward(argument: Argument): void {
                is_valid_source(argument, false);
                Console.obtained(argument.source);
                defined_or_default<Argument, string>(argument, "destination", `${Kernel.Path.except_extension(argument.source)}.xfl`);
                Console.output(argument.destination!);
                clock.start_safe();
                Kernel.Support.PopCap.Reanim.ToFlash.convert_fs(argument.source, argument.destination!);
                clock.stop_safe();
                return;
            },
            batch_forward(argument: BatchArgument): void {
                return basic_batch(this, argument, false);
            },
            is_enabled: true,
            configuration: undefined!,
            filter: ["file", /(.+)(\.reanim\.json)$/i],
        });
        return;
    }
}

Sen.Script.Executor.Methods.PopCap.Reanim.ToFlash.forward();
