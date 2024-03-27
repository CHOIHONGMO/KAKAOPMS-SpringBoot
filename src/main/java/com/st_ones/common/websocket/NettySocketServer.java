package com.st_ones.common.websocket;

public class NettySocketServer {


// SQL Server와 셋팅 시 톰캣서버 셧다운이 안되고 멈춰있는 버그 발생

//    @Autowired
//    @Qualifier("bossGroup")
//    private NioEventLoopGroup bossGroup;
//
//    @Autowired
//    @Qualifier("workerGroup")
//    private NioEventLoopGroup workerGroup;
//
//    @Autowired
//    @Qualifier("nettySocketServerHandler")
//    private NettySocketServerHandler nettySocketServerHandler;
//
//    private Channel channel;
//
//    void threadMessage(String message) {
//        String threadName = Thread.currentThread().getName();
//        System.err.println("thread name: " + threadName);
//    }
//
//    @PostConstruct
//    public void start() throws Exception {
//
//        NettySocketServerBody nssb = new NettySocketServerBody("Thread1");
//        Thread t1 = new Thread(nssb);
//
//        t1.start();
//    }
//
//    public ServerBootstrap bootstrap() {
//        ServerBootstrap sb = new ServerBootstrap();
//        sb.group(bossGroup, workerGroup)
//                .channel(NioServerSocketChannel.class)
//                .childHandler(nettySocketServerHandler)
//                .option(ChannelOption.SO_BACKLOG, 128)
//                .childOption(ChannelOption.SO_KEEPALIVE, true);
//
//        return sb;
//    }
//
//    @PreDestroy
//    public void stop() {
//
//    }
//
//    class NettySocketServerBody implements Runnable {
//
//        String name;
//
//        public NettySocketServerBody(String name) {
//            this.name = name;
//        }
//
//        @Override
//        public void run() {
//            try {
//                channel = bootstrap().bind(5010).sync().channel().closeFuture().sync().channel();
//            } catch(InterruptedException e) {
//                e.printStackTrace();
//            }
//        }
//    }
}
