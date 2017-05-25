package cn.edu.bnuz.steer


import grails.test.mixin.TestFor
import spock.lang.Specification

/**
 * See the API for {@link grails.test.mixin.web.ControllerUnitTestMixin} for usage instructions
 */
@TestFor(SheduleInterceptor)
class SheduleInterceptorSpec extends Specification {

    def setup() {
    }

    def cleanup() {

    }

    void "Test shedule interceptor matching"() {
        when:"A request matches the interceptor"
            withRequest(controller:"shedule")

        then:"The interceptor does match"
            interceptor.doesMatch()
    }
}
